"""Service orchestrator adhering to DIP (Dependency Inversion Principle)."""

from dataclasses import dataclass
from typing import Any, Dict, List, Optional
import numpy as np

from set_engine.models import (
    Card,
    DetectedCard,
    SetCombination,
)
from set_engine.detector import ICardDetector, validate_image_security
from set_engine.solver import ISetSolver
from set_engine.visualizer import ISetVisualizer


@dataclass
class SetAnalysisResult:
    """Complete outcome of card detection and SET identification."""
    cards: List[DetectedCard]
    sets: List[SetCombination]
    annotated_image: Optional[np.ndarray] = None

    @property
    def card_count(self) -> int:
        """Total number of cards detected."""
        return len(self.cards)

    @property
    def set_count(self) -> int:
        """Total number of SET combinations found."""
        return len(self.sets)

    def to_dict(self) -> Dict[str, Any]:
        """Convert analysis result to serializable dictionary."""
        return {
            "card_count": self.card_count,
            "set_count": self.set_count,
            "cards": [c.to_dict() for c in self.cards],
            "sets": [s.to_dict() for s in self.sets],
        }


SetDetectionResult = SetAnalysisResult


class SetService:
    """Orchestrates image validation, detection, solving, and annotation."""

    def __init__(
        self,
        detector: ICardDetector,
        solver: ISetSolver,
        visualizer: ISetVisualizer,
    ) -> None:
        self._detector = detector
        self._solver = solver
        self._visualizer = visualizer

    def process_image(
        self,
        image: np.ndarray,
        generate_visual: bool = True
    ) -> SetAnalysisResult:
        """Process input image, detect cards, find SETs, and optionally annotate."""
        validate_image_security(image)

        cards = self._detector.detect(image)
        sets = self._solver.find_sets(cards)

        annotated_image: Optional[np.ndarray] = None
        if generate_visual:
            annotated_image = self._visualizer.annotate(image, cards, sets)

        return SetAnalysisResult(
            cards=cards,
            sets=sets,
            annotated_image=annotated_image,
        )

    def solve_cards_directly(self, cards: List[Card]) -> List[SetCombination]:
        """Directly calculate SET combinations without image input."""
        from set_engine.models import BoundingBox
        dummy_box = BoundingBox(x1=0.0, y1=0.0, x2=0.0, y2=0.0, confidence=1.0)
        detected_cards = [
            DetectedCard(index=i, card=c, box=dummy_box)
            for i, c in enumerate(cards)
        ]
        return self._solver.find_sets(detected_cards)
