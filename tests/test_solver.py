"""Unit tests for FastSetSolver."""

from set_engine.models import BoundingBox, Card, DetectedCard
from set_engine.solver import FastSetSolver


def test_is_set_all_same_and_all_different() -> None:
    solver = FastSetSolver()

    # All attributes different
    c1 = Card.from_attributes(1, 1, 1, 1)
    c2 = Card.from_attributes(2, 2, 2, 2)
    c3 = Card.from_attributes(3, 3, 3, 3)
    assert solver.is_set(c1, c2, c3) is True

    # Same number, different other attributes
    c4 = Card.from_attributes(1, 1, 1, 1)
    c5 = Card.from_attributes(1, 2, 2, 2)
    c6 = Card.from_attributes(1, 3, 3, 3)
    assert solver.is_set(c4, c5, c6) is True

    # Two same, one different on shape -> NOT a set
    c7 = Card.from_attributes(1, 1, 1, 1)
    c8 = Card.from_attributes(2, 1, 2, 2)
    c9 = Card.from_attributes(3, 2, 3, 3)
    assert solver.is_set(c7, c8, c9) is False


def test_get_complement() -> None:
    solver = FastSetSolver()

    c1 = Card.from_attributes(1, 1, 2, 3)
    c2 = Card.from_attributes(2, 1, 3, 1)

    comp = solver.get_complement(c1, c2)
    # Number: 1, 2 -> 3
    # Shape: 1, 1 -> 1
    # Color: 2, 3 -> 1
    # Shading: 3, 1 -> 2
    assert comp.as_tuple() == (3, 1, 1, 2)
    assert solver.is_set(c1, c2, comp) is True


def test_find_sets_edge_cases() -> None:
    solver = FastSetSolver()
    box = BoundingBox(0, 0, 10, 10)

    # Empty and < 3 cards
    assert solver.find_sets([]) == []
    c1 = Card.from_attributes(1, 1, 1, 1)
    c2 = Card.from_attributes(2, 2, 2, 2)
    cards = [
        DetectedCard(index=0, card=c1, box=box),
        DetectedCard(index=1, card=c2, box=box),
    ]
    assert solver.find_sets(cards) == []


def test_find_sets_with_known_combinations() -> None:
    solver = FastSetSolver()
    box = BoundingBox(0, 0, 10, 10)

    c1 = Card.from_attributes(1, 1, 1, 1)
    c2 = Card.from_attributes(2, 2, 2, 2)
    c3 = Card.from_attributes(3, 3, 3, 3)  # forms set with 0, 1

    c4 = Card.from_attributes(1, 2, 3, 1)
    c5 = Card.from_attributes(2, 3, 1, 1)
    c6 = Card.from_attributes(3, 1, 2, 1)  # forms set with 3, 4

    board = [
        DetectedCard(index=0, card=c1, box=box),
        DetectedCard(index=1, card=c2, box=box),
        DetectedCard(index=2, card=c3, box=box),
        DetectedCard(index=3, card=c4, box=box),
        DetectedCard(index=4, card=c5, box=box),
        DetectedCard(index=5, card=c6, box=box),
    ]

    sets = solver.find_sets(board)
    assert len(sets) >= 2
    indices_list = [s.indices for s in sets]
    assert (0, 1, 2) in indices_list
    assert (3, 4, 5) in indices_list


def test_isetsolver_abstract() -> None:
    from set_engine.solver import ISetSolver
    import pytest

    class IncompleteSolver(ISetSolver):
        pass

    with pytest.raises(TypeError):
        IncompleteSolver()  # type: ignore
