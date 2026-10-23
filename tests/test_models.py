"""Unit tests for domain models."""

import pytest
from set_engine.models import (
    BoundingBox,
    Card,
    CardColor,
    CardNumber,
    CardShading,
    CardShape,
    DetectedCard,
    SetCombination,
)


def test_card_creation_and_attributes() -> None:
    card = Card.from_attributes(1, 2, 3, 1)
    assert card.number == CardNumber.ONE
    assert card.shape == CardShape.DIAMOND
    assert card.color == CardColor.PURPLE
    assert card.shading == CardShading.SOLID
    assert card.as_tuple() == (1, 2, 3, 1)

    card_dict = card.to_dict()
    assert card_dict == {
        "number": "ONE",
        "shape": "DIAMOND",
        "color": "PURPLE",
        "shading": "SOLID",
    }


def test_invalid_card_attributes() -> None:
    with pytest.raises(ValueError):
        Card.from_attributes(4, 1, 1, 1)

    with pytest.raises(ValueError):
        Card.from_attributes(1, 0, 1, 1)


def test_bounding_box() -> None:
    box = BoundingBox(x1=10.2, y1=20.7, x2=100.8, y2=200.1, confidence=0.95)
    assert box.to_int_coords() == (10, 21, 101, 200)

    box_dict = box.to_dict()
    assert box_dict["x1"] == 10.2
    assert box_dict["confidence"] == 0.95


def test_detected_card_and_set_combination() -> None:
    card1 = Card.from_attributes(1, 1, 1, 1)
    card2 = Card.from_attributes(2, 2, 2, 2)
    card3 = Card.from_attributes(3, 3, 3, 3)

    box = BoundingBox(0, 0, 10, 10)
    det1 = DetectedCard(index=0, card=card1, box=box)
    assert det1.to_dict()["index"] == 0
    assert det1.to_dict()["card"]["number"] == "ONE"

    comb = SetCombination(indices=(0, 1, 2), cards=(card1, card2, card3))
    comb_dict = comb.to_dict()
    assert comb_dict["indices"] == [0, 1, 2]
    assert len(comb_dict["cards"]) == 3
