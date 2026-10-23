"""Image annotation and visualization module for SET card detections."""

from abc import ABC, abstractmethod
from typing import List, Tuple
import cv2
import numpy as np

from set_engine.models import (
    DetectedCard,
    SetCombination,
)


class ISetVisualizer(ABC):
    """Interface for annotating detection and solution results on images (ISP)."""

    @abstractmethod
    def annotate(
        self,
        image: np.ndarray,
        detected_cards: List[DetectedCard],
        found_sets: List[SetCombination]
    ) -> np.ndarray:
        """Draw bounding boxes, card attributes, and SET connections onto the image."""
        pass


class SetVisualizer(ISetVisualizer):
    """OpenCV-based visualizer for highlighting SET combinations."""

    # 8 high-contrast colors (BGR format) for distinguishing multiple SETs
    SET_COLORS: List[Tuple[int, int, int]] = [
        (0, 215, 255),   # Golden Yellow
        (255, 128, 0),   # Neon Blue
        (50, 205, 50),   # Lime Green
        (204, 0, 204),   # Bright Magenta
        (0, 165, 255),   # Bright Orange
        (255, 0, 128),   # Violet
        (255, 255, 0),   # Cyan
        (147, 20, 255),  # Deep Pink
    ]

    NEUTRAL_COLOR: Tuple[int, int, int] = (180, 180, 180)
    FILL_ALPHA: float = 0.15

    @staticmethod
    def _clamp_coords(x: float, y: float, w: int, h: int) -> Tuple[int, int]:
        """Safely clamp coordinate floats to image boundaries."""
        cx = max(0, min(int(round(x)), w - 1))
        cy = max(0, min(int(round(y)), h - 1))
        return cx, cy

    def _draw_card_box(self, canvas: np.ndarray, card: DetectedCard, w: int, h: int) -> None:
        """Draw neutral bounding box and attribute/confidence label for a detected card."""
        x1, y1 = self._clamp_coords(card.box.x1, card.box.y1, w, h)
        x2, y2 = self._clamp_coords(card.box.x2, card.box.y2, w, h)

        cv2.rectangle(canvas, (x1, y1), (x2, y2), self.NEUTRAL_COLOR, 2)

        label = (
            f"#{card.index} {card.card.number.value}"
            f"-{card.card.shape.name[:3]}"
            f"-{card.card.color.name[:3]}"
            f"-{card.card.shading.name[:3]}"
            f" ({card.box.confidence:.2f})"
        )
        text_pos = (x1, max(y1 - 6, 12))
        cv2.putText(
            canvas, label, text_pos,
            cv2.FONT_HERSHEY_SIMPLEX, 0.42, self.NEUTRAL_COLOR, 1, cv2.LINE_AA
        )

    def _draw_set_overlay(
        self,
        canvas: np.ndarray,
        comb: SetCombination,
        set_idx: int,
        card_map: dict[int, DetectedCard],
        w: int,
        h: int,
    ) -> None:
        """Draw colored borders, semi-transparent triangle fill, and connecting polylines."""
        color = self.SET_COLORS[set_idx % len(self.SET_COLORS)]
        centers: List[Tuple[int, int]] = []

        for idx in comb.indices:
            if idx in card_map:
                card_item = card_map[idx]
                x1, y1 = self._clamp_coords(card_item.box.x1, card_item.box.y1, w, h)
                x2, y2 = self._clamp_coords(card_item.box.x2, card_item.box.y2, w, h)

                cv2.rectangle(canvas, (x1, y1), (x2, y2), color, 3)

                set_tag = f"SET #{set_idx + 1}"
                cv2.putText(
                    canvas, set_tag, (x1, min(y2 + 18, h - 5)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2, cv2.LINE_AA
                )
                centers.append(((x1 + x2) // 2, (y1 + y2) // 2))

        if len(centers) == 3:
            pts = np.array(centers, dtype=np.int32).reshape((-1, 1, 2))
            overlay = canvas.copy()
            cv2.fillPoly(overlay, [pts], color)
            cv2.addWeighted(overlay, self.FILL_ALPHA, canvas, 1.0 - self.FILL_ALPHA, 0, canvas)
            cv2.polylines(canvas, [pts], isClosed=True, color=color, thickness=2,
                          lineType=cv2.LINE_AA)

    def annotate(
        self,
        image: np.ndarray,
        detected_cards: List[DetectedCard],
        found_sets: List[SetCombination]
    ) -> np.ndarray:
        """Generate annotated image copy with all detected cards and identified SETs."""
        canvas = image.copy()
        height, width = canvas.shape[:2]

        card_map = {c.index: c for c in detected_cards}

        # 1. Draw all card boxes
        for item in detected_cards:
            self._draw_card_box(canvas, item, width, height)

        # 2. Draw SET highlights and connecting triangles
        for set_idx, comb in enumerate(found_sets):
            self._draw_set_overlay(canvas, comb, set_idx, card_map, width, height)

        return canvas
