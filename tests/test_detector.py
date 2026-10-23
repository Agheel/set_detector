"""Unit tests for card detectors and image security validation."""

from unittest.mock import MagicMock, patch
import numpy as np
import pytest

from set_engine.detector import (
    MockCardDetector,
    YoloCardDetector,
    validate_image_security,
)
from set_engine.models import Card


def test_validate_image_security() -> None:
    # 1. Non-numpy input
    with pytest.raises(TypeError):
        validate_image_security("not an array")  # type: ignore

    # 2. Wrong dtype
    float_img = np.zeros((100, 100, 3), dtype=np.float32)
    with pytest.raises(ValueError, match="Invalid image dtype"):
        validate_image_security(float_img)

    # 3. Wrong shape (2D grayscale or 4D)
    gray_img = np.zeros((100, 100), dtype=np.uint8)
    with pytest.raises(ValueError, match="3 color channels"):
        validate_image_security(gray_img)

    # 4. Too small
    small_img = np.zeros((20, 20, 3), dtype=np.uint8)
    with pytest.raises(ValueError, match="too small"):
        validate_image_security(small_img)

    # 5. Too large (DoS defense)
    large_img = np.zeros((500, 500, 3), dtype=np.uint8)
    with pytest.raises(ValueError, match="exceed maximum"):
        validate_image_security(large_img, max_dim=400)

    # 6. Valid image
    valid_img = np.zeros((100, 100, 3), dtype=np.uint8)
    validate_image_security(valid_img)  # Should not raise


def test_mock_card_detector() -> None:
    detector = MockCardDetector()
    img = np.zeros((300, 400, 3), dtype=np.uint8)
    cards = detector.detect(img)
    assert len(cards) == 12
    assert cards[0].index == 0
    assert cards[0].box.x1 < cards[0].box.x2

    # Custom card list
    custom_cards = [Card.from_attributes(1, 1, 1, 1)]
    detector_custom = MockCardDetector(predefined_cards=custom_cards)
    cards_custom = detector_custom.detect(img)
    assert len(cards_custom) == 1


def test_yolo_weights_path_validation(tmp_path: pytest.TempPathFactory) -> None:
    # Empty path
    with pytest.raises(ValueError, match="must be a non-empty string"):
        YoloCardDetector(weights_path="")

    # Disallowed extension
    with pytest.raises(ValueError, match="Allowed extensions"):
        YoloCardDetector(weights_path="model.bin")

    # Non-existent file
    with pytest.raises(FileNotFoundError):
        YoloCardDetector(weights_path="non_existent_weights.pt")


def test_class_id_to_card() -> None:
    # Test bounds
    with pytest.raises(ValueError):
        YoloCardDetector.class_id_to_card(-1)
    with pytest.raises(ValueError):
        YoloCardDetector.class_id_to_card(81)

    # Test round trip of all 81 classes
    for cid in range(81):
        card = YoloCardDetector.class_id_to_card(cid)
        assert 1 <= card.number <= 3
        assert 1 <= card.shape <= 3
        assert 1 <= card.color <= 3
        assert 1 <= card.shading <= 3


@patch("set_engine.detector.YoloCardDetector._load_yolo_model")
def test_yolo_detector_mocked_inference(
    mock_load: MagicMock,
    tmp_path: pytest.TempPathFactory
) -> None:
    # Create a dummy .pt file so path validation succeeds
    dummy_pt = tmp_path / "dummy.pt"
    dummy_pt.write_bytes(b"dummy")

    mock_model = MagicMock()
    mock_load.return_value = mock_model

    detector = YoloCardDetector(weights_path=str(dummy_pt), conf_threshold=0.6)

    img = np.zeros((200, 200, 3), dtype=np.uint8)

    # Scenario 1: Empty results
    mock_model.return_value = []
    assert detector.detect(img) == []

    # Scenario 2: Results with no boxes
    mock_res_empty = MagicMock()
    mock_res_empty.boxes = []
    mock_model.return_value = [mock_res_empty]
    assert detector.detect(img) == []

    # Scenario 3: Results with 1 valid box and 1 invalid class box
    box1 = MagicMock()
    box1.xyxy = [np.array([10.0, 20.0, 50.0, 60.0])]
    box1.conf = [MagicMock(item=lambda: 0.95)]
    box1.cls = [MagicMock(item=lambda: 0)]  # class 0 -> Card(1, 1, 1, 1)

    box2 = MagicMock()
    box2.xyxy = [np.array([70.0, 80.0, 90.0, 100.0])]
    box2.conf = [MagicMock(item=lambda: 0.88)]
    box2.cls = [MagicMock(item=lambda: 999)]  # Out-of-range class (skipped)

    mock_res = MagicMock()
    mock_res.boxes = [box1, box2]
    mock_model.return_value = [mock_res]

    detected = detector.detect(img)
    assert len(detected) == 1
    assert detected[0].card.number == 1
    assert detected[0].box.x1 == 10.0


def test_icard_detector_abstract() -> None:
    from set_engine.detector import ICardDetector

    class IncompleteDetector(ICardDetector):
        pass

    with pytest.raises(TypeError):
        IncompleteDetector()  # type: ignore


def test_yolo_load_model_error() -> None:
    with pytest.raises(RuntimeError, match="Failed to load YOLO model"):
        # Passing an invalid or non-existent file path directly to _load_yolo_model
        YoloCardDetector._load_yolo_model("non_existent_invalid_path.pt")
