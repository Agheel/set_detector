"""Unit tests for image visualizer."""

import numpy as np
from set_engine.models import BoundingBox, Card, DetectedCard, SetCombination
from set_engine.visualizer import SetVisualizer


def test_visualizer_annotation() -> None:
    visualizer = SetVisualizer()
    img = np.zeros((300, 300, 3), dtype=np.uint8)

    card1 = Card.from_attributes(1, 1, 1, 1)
    card2 = Card.from_attributes(2, 2, 2, 2)
    card3 = Card.from_attributes(3, 3, 3, 3)

    # Box with coordinates that stretch beyond bounds to test clamp
    b1 = BoundingBox(-10.0, -10.0, 50.0, 50.0)
    b2 = BoundingBox(60.0, 60.0, 100.0, 100.0)
    b3 = BoundingBox(110.0, 110.0, 400.0, 400.0)

    det_cards = [
        DetectedCard(index=0, card=card1, box=b1),
        DetectedCard(index=1, card=card2, box=b2),
        DetectedCard(index=2, card=card3, box=b3),
    ]

    comb = SetCombination(indices=(0, 1, 2), cards=(card1, card2, card3))

    annotated = visualizer.annotate(img, det_cards, [comb])

    # Check that original image wasn't modified
    assert np.all(img == 0)
    # Check that annotated image has content drawn (some pixels are non-zero)
    assert np.any(annotated > 0)
    assert annotated.shape == img.shape


def test_isetvisualizer_abstract() -> None:
    import pytest
    from set_engine.visualizer import ISetVisualizer

    class IncompleteVisualizer(ISetVisualizer):
        pass

    with pytest.raises(TypeError):
        IncompleteVisualizer()  # type: ignore
