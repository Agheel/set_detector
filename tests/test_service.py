"""Unit tests for SetService orchestrator."""

import numpy as np
from set_engine.detector import MockCardDetector
from set_engine.models import Card
from set_engine.service import SetService
from set_engine.solver import FastSetSolver
from set_engine.visualizer import SetVisualizer


def test_service_pipeline() -> None:
    detector = MockCardDetector()
    solver = FastSetSolver()
    visualizer = SetVisualizer()

    service = SetService(detector, solver, visualizer)

    img = np.zeros((300, 400, 3), dtype=np.uint8)

    # 1. Process with visual
    result = service.process_image(img, generate_visual=True)
    assert result.card_count == 12
    assert result.set_count >= 1
    assert result.annotated_image is not None

    res_dict = result.to_dict()
    assert res_dict["card_count"] == 12
    assert res_dict["set_count"] == result.set_count

    # 2. Process without visual
    res_no_vis = service.process_image(img, generate_visual=False)
    assert res_no_vis.annotated_image is None


def test_service_solve_cards_directly() -> None:
    service = SetService(MockCardDetector(), FastSetSolver(), SetVisualizer())

    cards = [
        Card.from_attributes(1, 1, 1, 1),
        Card.from_attributes(2, 2, 2, 2),
        Card.from_attributes(3, 3, 3, 3),
    ]

    sets = service.solve_cards_directly(cards)
    assert len(sets) == 1
    assert sets[0].indices == (0, 1, 2)
