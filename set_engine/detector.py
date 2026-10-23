"""Card detector module with YOLO implementation and Mock detector for testing."""

from abc import ABC, abstractmethod
import os
from typing import Any, Dict, List, Optional
import numpy as np

from set_engine.models import (
    BoundingBox,
    Card,
    CardColor,
    CardNumber,
    CardShading,
    CardShape,
    DetectedCard,
)

DEFAULT_WEIGHTS_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "weights",
)
PREFERRED_WEIGHT_NAMES = ("best.pt", "set_yolo.pt", "model.pt", "best.onnx", "model.onnx")

_NUMBER_MAP: Dict[str, int] = {
    "1": int(CardNumber.ONE), "one": int(CardNumber.ONE),
    "2": int(CardNumber.TWO), "two": int(CardNumber.TWO),
    "3": int(CardNumber.THREE), "three": int(CardNumber.THREE),
}
_SHAPE_MAP: Dict[str, int] = {
    "oval": int(CardShape.OVAL), "ovals": int(CardShape.OVAL),
    "diamond": int(CardShape.DIAMOND), "diamonds": int(CardShape.DIAMOND),
    "squiggle": int(CardShape.SQUIGGLE), "squiggles": int(CardShape.SQUIGGLE),
}
_COLOR_MAP: Dict[str, int] = {
    "red": int(CardColor.RED),
    "green": int(CardColor.GREEN),
    "purple": int(CardColor.PURPLE),
}
_SHADING_MAP: Dict[str, int] = {
    "solid": int(CardShading.SOLID), "filled": int(CardShading.SOLID),
    "striped": int(CardShading.STRIPED), "shaded": int(CardShading.STRIPED),
    "open": int(CardShading.OPEN), "empty": int(CardShading.OPEN),
}


class ICardDetector(ABC):
    """Interface for card detection and attribute classification (DIP & ISP)."""

    @abstractmethod
    def detect(self, image: np.ndarray) -> List[DetectedCard]:
        """Detect cards and their attributes from an input image."""
        pass


def validate_image_security(image: np.ndarray, max_dim: int = 4096) -> None:
    """Validate image array against DoS attacks, format corruption, and memory bombs."""
    if not isinstance(image, np.ndarray):
        raise TypeError("Input image must be a numpy.ndarray.")

    if image.dtype != np.uint8:
        raise ValueError(f"Invalid image dtype: expected uint8, got {image.dtype}.")

    if image.ndim != 3 or image.shape[2] != 3:
        raise ValueError(f"Image must have 3 color channels (H, W, 3). Got shape {image.shape}.")

    height, width = image.shape[:2]
    if height < 32 or width < 32:
        raise ValueError(f"Image resolution too small ({width}x{height}). Minimum is 32x32.")

    if height > max_dim or width > max_dim:
        raise ValueError(
            f"Image dimensions ({width}x{height}) exceed maximum allowed dimension ({max_dim})."
        )


class MockCardDetector(ICardDetector):
    """Deterministic mock detector generating preset cards for testing and client dev."""

    def __init__(self, predefined_cards: Optional[List[Card]] = None) -> None:
        if predefined_cards is not None:
            self._cards = predefined_cards
        else:
            # Default 12 cards containing known valid SETs for verification
            # Set 1: (0, 1, 2)
            # Set 2: (3, 4, 5)
            self._cards = [
                Card.from_attributes(1, 1, 1, 1),
                Card.from_attributes(2, 2, 2, 2),
                Card.from_attributes(3, 3, 3, 3),  # Completes Set 1
                Card.from_attributes(1, 2, 3, 1),
                Card.from_attributes(2, 3, 1, 1),
                Card.from_attributes(3, 1, 2, 1),  # Completes Set 2
                Card.from_attributes(1, 1, 2, 2),
                Card.from_attributes(2, 1, 3, 2),
                Card.from_attributes(3, 2, 1, 3),
                Card.from_attributes(1, 3, 2, 1),
                Card.from_attributes(2, 2, 1, 3),
                Card.from_attributes(3, 3, 2, 2),
            ]

    def detect(self, image: np.ndarray) -> List[DetectedCard]:
        """Detect cards on a mock 3x4 grid based on input image dimensions."""
        validate_image_security(image)

        height, width = image.shape[:2]
        cols, rows = 4, 3
        cell_w = width / cols
        cell_h = height / rows

        detected: List[DetectedCard] = []
        for idx, card in enumerate(self._cards[:12]):
            r = idx // cols
            c = idx % cols
            pad_x = cell_w * 0.1
            pad_y = cell_h * 0.1
            box = BoundingBox(
                x1=c * cell_w + pad_x,
                y1=r * cell_h + pad_y,
                x2=(c + 1) * cell_w - pad_x,
                y2=(r + 1) * cell_h - pad_y,
                confidence=0.98,
            )
            detected.append(DetectedCard(index=idx, card=card, box=box))

        return detected


class YoloCardDetector(ICardDetector):
    """Ultralytics YOLO wrapper for SET card detection and attribute extraction."""

    ALLOWED_EXTENSIONS = (".pt", ".onnx")

    def __init__(self, weights_path: str, conf_threshold: float = 0.5) -> None:
        self._conf_threshold = conf_threshold
        self._weights_path = self._validate_and_resolve_weights_path(weights_path)
        self._model = self._load_yolo_model(self._weights_path)

    @property
    def weights_path(self) -> str:
        """Return resolved path of the loaded YOLO weights file."""
        return self._weights_path

    @classmethod
    def _validate_and_resolve_weights_path(cls, path: str) -> str:
        """Validate weights file path to prevent directory traversal and unauthorized formats."""
        if not path or not isinstance(path, str):
            raise ValueError("Weights path must be a non-empty string.")

        real_path = os.path.realpath(path)
        if not any(real_path.lower().endswith(ext) for ext in cls.ALLOWED_EXTENSIONS):
            raise ValueError(
                f"Invalid weights file extension in {path}. "
                f"Allowed extensions: {cls.ALLOWED_EXTENSIONS}"
            )

        if not os.path.isfile(real_path):
            raise FileNotFoundError(f"Model weights file not found at: {real_path}")

        return real_path

    @staticmethod
    def _load_yolo_model(weights_path: str) -> Any:
        """Safely import and initialize Ultralytics YOLO model."""
        try:
            from ultralytics import YOLO  # type: ignore
            return YOLO(weights_path)
        except Exception as exc:
            raise RuntimeError(f"Failed to load YOLO model: {exc}") from exc

    @staticmethod
    def class_id_to_card(class_id: int) -> Card:
        """Decode canonical 81-class index into Card domain entity."""
        if not (0 <= class_id < 81):
            raise ValueError(f"Invalid SET card class_id: {class_id}. Must be in range [0, 80].")

        num = (class_id // 27) + 1
        shape = ((class_id % 27) // 9) + 1
        color = ((class_id % 9) // 3) + 1
        shading = (class_id % 3) + 1

        return Card.from_attributes(num, shape, color, shading)

    @staticmethod
    def parse_class_label(label: str) -> Card:
        """Parse string label (e.g. '2_oval_red_solid') into Card domain entity."""
        normalized = label.strip().lower().replace("-", "_")
        tokens = [t for t in normalized.split("_") if t]
        if len(tokens) != 4:
            raise ValueError(f"Invalid class label format: '{label}'. Expected 4 tokens.")

        num = _NUMBER_MAP.get(tokens[0])
        shape = _SHAPE_MAP.get(tokens[1])
        color = _COLOR_MAP.get(tokens[2])
        shading = _SHADING_MAP.get(tokens[3])

        if num is None or shape is None or color is None or shading is None:
            raise ValueError(f"Unrecognized card attributes in label: '{label}'.")

        return Card.from_attributes(num, shape, color, shading)

    def _resolve_card(self, cls_id: int, names: Any) -> Card:
        """Resolve Card from model label dictionary or fallback to canonical 81-class ID."""
        if isinstance(names, dict) and cls_id in names:
            raw_label = str(names[cls_id])
            if "_" in raw_label or "-" in raw_label:
                return self.parse_class_label(raw_label)
        return self.class_id_to_card(cls_id)

    def detect(self, image: np.ndarray) -> List[DetectedCard]:
        """Run YOLO inference on validated image and parse detected cards."""
        validate_image_security(image)

        results = self._model(image, conf=self._conf_threshold, verbose=False)
        detected: List[DetectedCard] = []

        if not results:
            return detected

        first_res = results[0]
        boxes = getattr(first_res, "boxes", None)
        if boxes is None or len(boxes) == 0:
            return detected

        names = getattr(first_res, "names", getattr(self._model, "names", None))

        for idx, box_item in enumerate(boxes):
            coords = box_item.xyxy[0].tolist()
            conf = float(box_item.conf[0].item())
            cls_id = int(box_item.cls[0].item())

            try:
                card = self._resolve_card(cls_id, names)
            except ValueError:
                continue

            box = BoundingBox(
                x1=float(coords[0]),
                y1=float(coords[1]),
                x2=float(coords[2]),
                y2=float(coords[3]),
                confidence=conf,
            )
            detected.append(DetectedCard(index=idx, card=card, box=box))

        return detected


def discover_weights_path(weights_dir: str = DEFAULT_WEIGHTS_DIR) -> Optional[str]:
    """Auto-discover YOLO weights from SET_YOLO_WEIGHTS env var or weights/ directory."""
    env_path = os.getenv("SET_YOLO_WEIGHTS", "").strip()
    if env_path and os.path.isfile(env_path):
        return env_path

    if not os.path.isdir(weights_dir):
        return None

    for preferred in PREFERRED_WEIGHT_NAMES:
        candidate = os.path.join(weights_dir, preferred)
        if os.path.isfile(candidate):
            return candidate

    for entry in sorted(os.listdir(weights_dir)):
        if entry.lower().endswith(YoloCardDetector.ALLOWED_EXTENSIONS):
            full_path = os.path.join(weights_dir, entry)
            if os.path.isfile(full_path):
                return full_path

    return None
