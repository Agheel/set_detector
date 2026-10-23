"""Mathematical SET solver module adhering to SOLID (SRP, DIP) principles."""

from abc import ABC, abstractmethod
from typing import Dict, List, Tuple
from set_engine.models import (
    Card,
    DetectedCard,
    SetCombination,
)


class ISetSolver(ABC):
    """Interface for SET identification algorithms (DIP & ISP)."""

    @abstractmethod
    def is_set(self, card1: Card, card2: Card, card3: Card) -> bool:
        """Verify whether three given cards form a valid SET."""
        pass

    @abstractmethod
    def get_complement(self, card1: Card, card2: Card) -> Card:
        """Calculate the unique 3rd card that completes a SET with two given cards."""
        pass

    @abstractmethod
    def find_sets(self, detected_cards: List[DetectedCard]) -> List[SetCombination]:
        """Find all valid SET combinations among detected cards on board."""
        pass


class FastSetSolver(ISetSolver):
    """Optimal O(N^2) SET solver using finite geometry complement mapping."""

    @staticmethod
    def _attribute_complement(val1: int, val2: int) -> int:
        """Compute the 3rd attribute value completing the set in GF(3)."""
        if val1 == val2:
            return val1
        return 6 - val1 - val2

    def is_set(self, card1: Card, card2: Card, card3: Card) -> bool:
        """Check if three cards satisfy all-same or all-different on all 4 attributes."""
        t1 = card1.as_tuple()
        t2 = card2.as_tuple()
        t3 = card3.as_tuple()

        for idx in range(4):
            if (t1[idx] + t2[idx] + t3[idx]) % 3 != 0:
                return False
        return True

    def get_complement(self, card1: Card, card2: Card) -> Card:
        """Determine the unique 3rd card completing a SET with card1 and card2."""
        t1 = card1.as_tuple()
        t2 = card2.as_tuple()

        comp_attrs = [
            self._attribute_complement(t1[i], t2[i])
            for i in range(4)
        ]

        return Card.from_attributes(
            comp_attrs[0],
            comp_attrs[1],
            comp_attrs[2],
            comp_attrs[3],
        )

    def find_sets(self, detected_cards: List[DetectedCard]) -> List[SetCombination]:
        """Find all valid 3-card SET combinations using complement lookup in O(N^2)."""
        if len(detected_cards) < 3:
            return []

        # Map card tuple to list of indices where this card appears on the board
        card_lookup: Dict[Tuple[int, int, int, int], List[int]] = {}
        for item in detected_cards:
            key = item.card.as_tuple()
            if key not in card_lookup:
                card_lookup[key] = []
            card_lookup[key].append(item.index)

        found_sets: List[SetCombination] = []
        num_cards = len(detected_cards)

        for i in range(num_cards):
            card_i = detected_cards[i].card
            for j in range(i + 1, num_cards):
                card_j = detected_cards[j].card
                complement = self.get_complement(card_i, card_j)
                comp_key = complement.as_tuple()

                if comp_key in card_lookup:
                    for k in card_lookup[comp_key]:
                        # Only record when indices are ordered i < j < k to prevent duplicates
                        if k > j:
                            comb = SetCombination(
                                indices=(detected_cards[i].index,
                                         detected_cards[j].index,
                                         k),
                                cards=(card_i, card_j, complement),
                            )
                            found_sets.append(comb)

        return found_sets
