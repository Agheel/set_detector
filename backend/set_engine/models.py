"""Domain models for SET card game adhering to SOLID principles."""

from dataclasses import dataclass
from enum import IntEnum
from typing import Any, Dict, Tuple


class CardNumber(IntEnum):
    """Number of symbols on the card (1, 2, 3)."""
    ONE = 1
    TWO = 2
    THREE = 3


class CardShape(IntEnum):
    """Shape of the symbols (Oval, Diamond, Squiggle)."""
    OVAL = 1
    DIAMOND = 2
    SQUIGGLE = 3


class CardColor(IntEnum):
    """Color of the symbols (Red, Green, Purple)."""
    RED = 1
    GREEN = 2
    PURPLE = 3


class CardShading(IntEnum):
    """Shading/filling of the symbols (Solid, Striped, Open)."""
    SOLID = 1
    STRIPED = 2
    OPEN = 3


@dataclass(frozen=True)
class Card:
    """Immutable domain representation of a SET card (SRP: Pure data)."""
    number: CardNumber
    shape: CardShape
    color: CardColor
    shading: CardShading

    def as_tuple(self) -> Tuple[int, int, int, int]:
        """Return the tuple of integer values for mathematical operations."""
        return (int(self.number), int(self.shape), int(self.color), int(self.shading))

    def to_dict(self) -> Dict[str, str]:
        """Convert card attributes to human-readable dictionary."""
        return {
            "number": self.number.name,
            "shape": self.shape.name,
            "color": self.color.name,
            "shading": self.shading.name,
        }

    @classmethod
    def from_attributes(
        cls,
        number: int,
        shape: int,
        color: int,
        shading: int
    ) -> "Card":
        """Create a Card from integer attribute values with validation."""
        return cls(
            number=CardNumber(number),
            shape=CardShape(shape),
            color=CardColor(color),
            shading=CardShading(shading),
        )


@dataclass(frozen=True)
class BoundingBox:
    """Bounding box coordinates for detected cards in an image."""
    x1: float
    y1: float
    x2: float
    y2: float
    confidence: float = 1.0

    def to_int_coords(self) -> Tuple[int, int, int, int]:
        """Return integer pixel coordinates (x1, y1, x2, y2)."""
        return (int(round(self.x1)), int(round(self.y1)),
                int(round(self.x2)), int(round(self.y2)))

    def to_dict(self) -> Dict[str, float]:
        """Serialize bounding box to dictionary."""
        return {
            "x1": self.x1,
            "y1": self.y1,
            "x2": self.x2,
            "y2": self.y2,
            "confidence": self.confidence,
        }


@dataclass(frozen=True)
class DetectedCard:
    """Card with its detected location on board."""
    index: int
    card: Card
    box: BoundingBox

    def to_dict(self) -> Dict[str, Any]:
        """Serialize detected card to dictionary."""
        return {
            "index": self.index,
            "card": self.card.to_dict(),
            "box": self.box.to_dict(),
        }


@dataclass(frozen=True)
class SetCombination:
    """A valid 3-card SET combination identified on the board."""
    indices: Tuple[int, int, int]
    cards: Tuple[Card, Card, Card]

    def to_dict(self) -> Dict[str, Any]:
        """Serialize set combination to dictionary."""
        return {
            "indices": list(self.indices),
            "cards": [c.to_dict() for c in self.cards],
        }
