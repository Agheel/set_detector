"""Tests verifying newly added ARCHITECTURE.md specifications and drop-in YOLO weights."""

import io
import time
from unittest.mock import MagicMock, patch
import cv2
from fastapi.testclient import TestClient
import numpy as np
import pytest

from api import app
from set_engine import (
    BoundingBox,
    DetectedCard,
    FastSetSolver,
    SetDetectionResult,
    YoloCardDetector,
    discover_weights_path,
)

client = TestClient(app)


def test_parse_class_label_spec() -> None:
    """Verify FR-02 / F-02 string label parsing (e.g., '2_oval_red_solid')."""
    card = YoloCardDetector.parse_class_label("2_oval_red_solid")
    assert card.as_tuple() == (2, 1, 1, 1)

    card_hyphen = YoloCardDetector.parse_class_label("three-diamond-purple-open")
    assert card_hyphen.as_tuple() == (3, 2, 3, 3)

    with pytest.raises(ValueError, match="Expected 4 tokens"):
        YoloCardDetector.parse_class_label("invalid_token")

    with pytest.raises(ValueError, match="Unrecognized card attributes"):
        YoloCardDetector.parse_class_label("2_circle_blue_solid")


def test_drop_in_weights_discovery(tmp_path: pytest.TempPathFactory) -> None:
    """Verify FR-06 automatic YOLO weights discovery from weights/ directory."""
    weights_dir = tmp_path / "weights"
    weights_dir.mkdir()

    with patch.dict("os.environ", {"SET_YOLO_WEIGHTS": ""}):
        # Empty directory -> None
        assert discover_weights_path(str(weights_dir)) is None
        assert discover_weights_path(str(tmp_path / "missing_dir")) is None

        # Non-weight file ignored
        readme = weights_dir / "README.md"
        readme.write_text("info")
        assert discover_weights_path(str(weights_dir)) is None

        # Arbitrary .pt file dropped into weights/ is discovered automatically
        custom_pt = weights_dir / "my_custom_yolo11.pt"
        custom_pt.write_bytes(b"dummy_pt")
        assert discover_weights_path(str(weights_dir)) == str(custom_pt)

        # Preferred name (best.pt) takes priority over arbitrary name
        best_pt = weights_dir / "best.pt"
        best_pt.write_bytes(b"best_pt")
        assert discover_weights_path(str(weights_dir)) == str(best_pt)

    # Environment variable takes highest priority
    with patch.dict("os.environ", {"SET_YOLO_WEIGHTS": str(custom_pt)}):
        assert discover_weights_path(str(weights_dir)) == str(custom_pt)


@patch("set_engine.detector.YoloCardDetector._load_yolo_model")
def test_yolo_detector_label_resolution(
    mock_load: MagicMock,
    tmp_path: pytest.TempPathFactory,
) -> None:
    """Verify YoloCardDetector resolves both string label maps and numeric IDs."""
    dummy_pt = tmp_path / "best.pt"
    dummy_pt.write_bytes(b"dummy")

    mock_model = MagicMock()
    mock_load.return_value = mock_model

    detector = YoloCardDetector(weights_path=str(dummy_pt))
    assert detector.weights_path.endswith("best.pt")

    box_str = MagicMock()
    box_str.xyxy = [np.array([10.0, 10.0, 50.0, 50.0])]
    box_str.conf = [MagicMock(item=lambda: 0.99)]
    box_str.cls = [MagicMock(item=lambda: 0)]

    mock_res = MagicMock()
    mock_res.names = {0: "2_oval_red_solid"}
    mock_res.boxes = [box_str]
    mock_model.return_value = [mock_res]

    img = np.zeros((100, 100, 3), dtype=np.uint8)
    detected = detector.detect(img)
    assert len(detected) == 1
    assert detected[0].card.as_tuple() == (2, 1, 1, 1)


def test_webp_magic_bytes_and_resolution_http_400() -> None:
    """Verify F-01 WebP header check (RIFF....WEBP) and resolution HTTP 400 defense."""
    # Invalid RIFF (not WEBP at offset 8) -> 415
    fake_riff = b"RIFF1234WAVEfmt "
    files_riff = {"file": ("audio.wav", io.BytesIO(fake_riff), "image/webp")}
    res_riff = client.post("/api/v1/detect", files=files_riff)
    assert res_riff.status_code == 415

    # Valid WebP magic header with corrupt body -> 400 bitmap decode error
    corrupt_webp = b"RIFF\x00\x00\x00\x00WEBPcorrupt"
    files_webp = {"file": ("corrupt.webp", io.BytesIO(corrupt_webp), "image/webp")}
    res_webp = client.post("/api/v1/detect", files=files_webp)
    assert res_webp.status_code == 400

    # Image smaller than 32x32 -> HTTP 400 Bad Request (Decompression / Resolution check)
    tiny_img = np.zeros((16, 16, 3), dtype=np.uint8)
    success, buf = cv2.imencode(".png", tiny_img)
    assert success
    files_tiny = {"file": ("tiny.png", io.BytesIO(buf.tobytes()), "image/png")}
    res_tiny = client.post("/api/v1/detect", files=files_tiny)
    assert res_tiny.status_code == 400
    assert "too small" in res_tiny.json()["detail"].lower()


def test_nfr02_solver_performance_under_5ms() -> None:
    """Verify NFR-02: 15-card board SET solving completes well within 5ms."""
    solver = FastSetSolver()
    box = BoundingBox(0, 0, 50, 50)
    cards = [
        DetectedCard(
            index=i,
            card=YoloCardDetector.class_id_to_card(i * 5 % 81),
            box=box,
        )
        for i in range(15)
    ]

    start = time.perf_counter()
    sets = solver.find_sets(cards)
    elapsed_ms = (time.perf_counter() - start) * 1000.0

    assert elapsed_ms < 5.0
    assert isinstance(sets, list)
    assert SetDetectionResult is not None
