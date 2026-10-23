"""Unit and integration tests for FastAPI REST API endpoints."""

import io
from unittest.mock import patch
import cv2
from fastapi.testclient import TestClient
import numpy as np
import pytest

from api import app, _init_default_detector


client = TestClient(app)


def _generate_valid_jpeg() -> bytes:
    """Generate a minimal valid 3-channel JPEG image byte stream."""
    img = np.zeros((100, 100, 3), dtype=np.uint8)
    success, buffer = cv2.imencode(".jpg", img)
    assert success
    return buffer.tobytes()


def test_health_check() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "detector" in data


def test_detect_endpoint_valid_image() -> None:
    jpeg_bytes = _generate_valid_jpeg()
    files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}

    response = client.post("/api/v1/detect", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["card_count"] == 12
    assert data["set_count"] >= 1
    assert "annotated_image_base64" in data
    assert data["annotated_image_base64"].startswith("data:image/jpeg;base64,")


def test_detect_endpoint_no_visual() -> None:
    jpeg_bytes = _generate_valid_jpeg()
    files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}

    response = client.post("/api/v1/detect?include_base64=false", files=files)
    assert response.status_code == 200
    data = response.json()
    assert "annotated_image_base64" not in data


def test_detect_image_endpoint() -> None:
    jpeg_bytes = _generate_valid_jpeg()
    files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}

    response = client.post("/api/v1/detect/image", files=files)
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/jpeg"
    assert len(response.content) > 0


def test_detect_empty_file() -> None:
    files = {"file": ("empty.jpg", io.BytesIO(b""), "image/jpeg")}
    response = client.post("/api/v1/detect", files=files)
    assert response.status_code == 400
    assert "empty" in response.json()["detail"].lower()


def test_detect_invalid_mime_file() -> None:
    files = {"file": ("test.txt", io.BytesIO(b"this is plain text"), "text/plain")}
    response = client.post("/api/v1/detect", files=files)
    assert response.status_code == 415
    assert "unsupported" in response.json()["detail"].lower()


def test_detect_oversized_file() -> None:
    large_payload = b"\xff\xd8\xff" + b"0" * (6 * 1024 * 1024)
    files = {"file": ("large.jpg", io.BytesIO(large_payload), "image/jpeg")}
    response = client.post("/api/v1/detect", files=files)
    assert response.status_code == 413
    assert "exceeds" in response.json()["detail"].lower()


def test_solve_endpoint() -> None:
    # 3 cards forming a set
    payload = {
        "cards": [
            {"number": 1, "shape": 1, "color": 1, "shading": 1},
            {"number": 2, "shape": 2, "color": 2, "shading": 2},
            {"number": 3, "shape": 3, "color": 3, "shading": 3},
        ]
    }
    response = client.post("/api/v1/solve", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["card_count"] == 3
    assert data["set_count"] == 1
    assert data["sets"][0]["indices"] == [0, 1, 2]

    # Invalid card number (e.g. 5)
    invalid_payload = {
        "cards": [
            {"number": 5, "shape": 1, "color": 1, "shading": 1}
        ]
    }
    res_invalid = client.post("/api/v1/solve", json=invalid_payload)
    assert res_invalid.status_code == 422


def test_init_default_detector(tmp_path: pytest.TempPathFactory) -> None:
    with patch.dict("os.environ", {"SET_YOLO_WEIGHTS": ""}):
        det = _init_default_detector()
        assert det.__class__.__name__ == "MockCardDetector"

    dummy_pt = tmp_path / "valid.pt"
    dummy_pt.write_bytes(b"dummy")

    with patch.dict("os.environ", {"SET_YOLO_WEIGHTS": str(dummy_pt)}):
        with patch("set_engine.detector.YoloCardDetector._load_yolo_model"):
            det2 = _init_default_detector()
            assert det2.__class__.__name__ == "YoloCardDetector"

        # Test failure in load_yolo_model falls back to MockCardDetector
        with patch("set_engine.detector.YoloCardDetector._load_yolo_model",
                   side_effect=RuntimeError("load failed")):
            det3 = _init_default_detector()
            assert det3.__class__.__name__ == "MockCardDetector"


def test_detect_corrupt_bitmap() -> None:
    # Magic bytes for JPEG followed by corrupt data
    corrupt_jpeg = b"\xff\xd8\xff\xe0" + b"random corrupt garbage"
    files = {"file": ("corrupt.jpg", io.BytesIO(corrupt_jpeg), "image/jpeg")}
    response = client.post("/api/v1/detect", files=files)
    assert response.status_code == 400
    assert "bitmap" in response.json()["detail"].lower()


def test_detect_service_error() -> None:
    jpeg_bytes = _generate_valid_jpeg()
    files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}

    with patch("api.service.process_image", side_effect=ValueError("Internal error")):
        response = client.post("/api/v1/detect", files=files)
        assert response.status_code == 422


def test_detect_image_visual_errors() -> None:
    jpeg_bytes = _generate_valid_jpeg()

    # 1. Annotated image is None
    from set_engine.service import SetAnalysisResult
    mock_res_none = SetAnalysisResult(cards=[], sets=[], annotated_image=None)
    with patch("api.service.process_image", return_value=mock_res_none):
        files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}
        response = client.post("/api/v1/detect/image", files=files)
        assert response.status_code == 500

    # 2. imencode fails
    mock_res_valid = SetAnalysisResult(
        cards=[], sets=[], annotated_image=np.zeros((10, 10, 3), dtype=np.uint8)
    )
    with patch("api.service.process_image", return_value=mock_res_valid):
        with patch("cv2.imencode", return_value=(False, None)):
            files = {"file": ("test.jpg", io.BytesIO(jpeg_bytes), "image/jpeg")}
            response = client.post("/api/v1/detect/image", files=files)
            assert response.status_code == 500
