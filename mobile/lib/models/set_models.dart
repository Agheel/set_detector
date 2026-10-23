import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CardNumber {
  one(1),
  two(2),
  three(3);

  final int value;
  const CardNumber(this.value);

  static CardNumber fromValue(dynamic raw) {
    if (raw is int) {
      return CardNumber.values.firstWhere(
        (e) => e.value == raw,
        orElse: () => CardNumber.one,
      );
    }
    final upper = raw.toString().toUpperCase();
    if (upper == 'TWO' || upper == '2') return CardNumber.two;
    if (upper == 'THREE' || upper == '3') return CardNumber.three;
    return CardNumber.one;
  }
}

enum CardShape {
  oval(1, '타원'),
  diamond(2, '다이아'),
  squiggle(3, '물결');

  final int value;
  final String koreanLabel;
  const CardShape(this.value, this.koreanLabel);

  static CardShape fromValue(dynamic raw) {
    if (raw is int) {
      return CardShape.values.firstWhere(
        (e) => e.value == raw,
        orElse: () => CardShape.oval,
      );
    }
    final upper = raw.toString().toUpperCase();
    if (upper == 'DIAMOND' || upper == '2') return CardShape.diamond;
    if (upper == 'SQUIGGLE' || upper == '3') return CardShape.squiggle;
    return CardShape.oval;
  }
}

enum CardColor {
  red(1, '빨강', SetColors.symbolRed),
  green(2, '초록', SetColors.symbolGreen),
  purple(3, '보라', SetColors.symbolPurple);

  final int value;
  final String koreanLabel;
  final Color color;
  const CardColor(this.value, this.koreanLabel, this.color);

  static CardColor fromValue(dynamic raw) {
    if (raw is int) {
      return CardColor.values.firstWhere(
        (e) => e.value == raw,
        orElse: () => CardColor.red,
      );
    }
    final upper = raw.toString().toUpperCase();
    if (upper == 'GREEN' || upper == '2') return CardColor.green;
    if (upper == 'PURPLE' || upper == '3') return CardColor.purple;
    return CardColor.red;
  }
}

enum CardShading {
  solid(1, '채움'),
  striped(2, '줄무늬'),
  open(3, '비움');

  final int value;
  final String koreanLabel;
  const CardShading(this.value, this.koreanLabel);

  static CardShading fromValue(dynamic raw) {
    if (raw is int) {
      return CardShading.values.firstWhere(
        (e) => e.value == raw,
        orElse: () => CardShading.solid,
      );
    }
    final upper = raw.toString().toUpperCase();
    if (upper == 'STRIPED' || upper == '2') return CardShading.striped;
    if (upper == 'OPEN' || upper == '3') return CardShading.open;
    return CardShading.solid;
  }
}

@immutable
class SetCard {
  final CardNumber number;
  final CardShape shape;
  final CardColor color;
  final CardShading shading;

  const SetCard({
    required this.number,
    required this.shape,
    required this.color,
    required this.shading,
  });

  factory SetCard.fromAttributes(int number, int shape, int color, int shading) {
    return SetCard(
      number: CardNumber.fromValue(number),
      shape: CardShape.fromValue(shape),
      color: CardColor.fromValue(color),
      shading: CardShading.fromValue(shading),
    );
  }

  factory SetCard.fromJson(Map<String, dynamic> json) {
    return SetCard(
      number: CardNumber.fromValue(json['number']),
      shape: CardShape.fromValue(json['shape']),
      color: CardColor.fromValue(json['color']),
      shading: CardShading.fromValue(json['shading']),
    );
  }

  Map<String, int> toSolveJson() => {
        'number': number.value,
        'shape': shape.value,
        'color': color.value,
        'shading': shading.value,
      };
}

@immutable
class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double confidence;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.confidence = 0.99,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

@immutable
class DetectedCardItem {
  final int index; // 0-based index (displayed as 01..12 in UI)
  final SetCard card;
  final BoundingBox box;

  const DetectedCardItem({
    required this.index,
    required this.card,
    required this.box,
  });

  String get displayNumber => (index + 1).toString().padLeft(2, '0');

  factory DetectedCardItem.fromJson(Map<String, dynamic> json) {
    return DetectedCardItem(
      index: json['index'] as int,
      card: SetCard.fromJson(json['card'] as Map<String, dynamic>),
      box: BoundingBox.fromJson(json['box'] as Map<String, dynamic>),
    );
  }
}

@immutable
class SetCombinationItem {
  final List<int> indices; // 0-based indices of the 3 cards
  final List<SetCard> cards;

  const SetCombinationItem({
    required this.indices,
    required this.cards,
  });

  List<String> get displayNumbers =>
      indices.map((i) => (i + 1).toString().padLeft(2, '0')).toList();

  String get formattedReference => displayNumbers.join(' · ');

  /// Dynamically compute the 4 attribute rule labels shown in Figma Screen 04 ('모양 일치', '색상 다름', etc.)
  List<String> get attributeRules {
    if (cards.length < 3) {
      return const ['모양 일치', '색상 다름', '개수 다름', '채움 일치'];
    }
    final sameShape =
        cards[0].shape == cards[1].shape && cards[1].shape == cards[2].shape;
    final sameColor =
        cards[0].color == cards[1].color && cards[1].color == cards[2].color;
    final sameNumber =
        cards[0].number == cards[1].number && cards[1].number == cards[2].number;
    final sameShading = cards[0].shading == cards[1].shading &&
        cards[1].shading == cards[2].shading;

    return [
      sameShape ? '모양 일치' : '모양 다름',
      sameColor ? '색상 일치' : '색상 다름',
      sameNumber ? '개수 일치' : '개수 다름',
      sameShading ? '채움 일치' : '채움 다름',
    ];
  }

  factory SetCombinationItem.fromJson(Map<String, dynamic> json) {
    final rawIndices = (json['indices'] as List<dynamic>).cast<int>();
    final rawCards = (json['cards'] as List<dynamic>)
        .map((c) => SetCard.fromJson(c as Map<String, dynamic>))
        .toList();
    return SetCombinationItem(indices: rawIndices, cards: rawCards);
  }
}

@immutable
class DetectionResultData {
  final List<DetectedCardItem> cards;
  final List<SetCombinationItem> sets;
  final String? annotatedImageBase64;

  const DetectionResultData({
    required this.cards,
    required this.sets,
    this.annotatedImageBase64,
  });

  int get cardCount => cards.length;
  int get setCount => sets.length;

  factory DetectionResultData.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>)
        .map((c) => DetectedCardItem.fromJson(c as Map<String, dynamic>))
        .toList();
    final sets = (json['sets'] as List<dynamic>)
        .map((s) => SetCombinationItem.fromJson(s as Map<String, dynamic>))
        .toList();
    return DetectionResultData(
      cards: cards,
      sets: sets,
      annotatedImageBase64: json['annotated_image_base64'] as String?,
    );
  }

  /// Exact 12-card board and 3 SET combinations from Figma Screen 03 & 04:
  /// SET 01: 01 · 02 · 05
  /// SET 02: 04 · 11 · 12
  /// SET 03: 06 · 10 · 12
  static DetectionResultData figmaThreeSetsPreset() {
    final presetCards = <SetCard>[
      // 01 (index 0): 1 purple solid squiggle
      SetCard.fromAttributes(1, 3, 3, 1),
      // 02 (index 1): 2 green striped diamond
      SetCard.fromAttributes(2, 2, 2, 2),
      // 03 (index 2): 2 red solid oval
      SetCard.fromAttributes(2, 1, 1, 1),
      // 04 (index 3): 3 purple solid oval
      SetCard.fromAttributes(3, 1, 3, 1),
      // 05 (index 4): 3 red open oval -> completes SET 01 with 01 & 02
      SetCard.fromAttributes(3, 1, 1, 3),
      // 06 (index 5): 3 red open oval
      SetCard.fromAttributes(3, 1, 1, 3),
      // 07 (index 6): 1 red open diamond
      SetCard.fromAttributes(1, 2, 1, 3),
      // 08 (index 7): 3 purple striped squiggle
      SetCard.fromAttributes(3, 3, 3, 2),
      // 09 (index 8): 3 green open squiggle
      SetCard.fromAttributes(3, 3, 2, 3),
      // 10 (index 9): 2 green open oval
      SetCard.fromAttributes(2, 1, 2, 3),
      // 11 (index 10): 2 purple striped oval
      SetCard.fromAttributes(2, 1, 3, 2),
      // 12 (index 11): 1 purple open oval -> completes SET 02 (04·11·12) & SET 03 (06·10·12)
      SetCard.fromAttributes(1, 1, 3, 3),
    ];

    final detected = List<DetectedCardItem>.generate(
      presetCards.length,
      (i) => DetectedCardItem(
        index: i,
        card: presetCards[i],
        box: BoundingBox(
          x1: (i % 3) * 116.0,
          y1: (i ~/ 3) * 92.0,
          x2: (i % 3) * 116.0 + 96.0,
          y2: (i ~/ 3) * 92.0 + 88.0,
        ),
      ),
    );

    final sets = <SetCombinationItem>[
      SetCombinationItem(
        indices: const [0, 1, 4], // 01 · 02 · 05
        cards: [presetCards[0], presetCards[1], presetCards[4]],
      ),
      SetCombinationItem(
        indices: const [3, 10, 11], // 04 · 11 · 12
        cards: [presetCards[3], presetCards[10], presetCards[11]],
      ),
      SetCombinationItem(
        indices: const [5, 9, 11], // 06 · 10 · 12
        cards: [presetCards[5], presetCards[9], presetCards[11]],
      ),
    ];

    return DetectionResultData(cards: detected, sets: sets);
  }

  /// Exact 12-card board with 0 SETs from Figma Screen 05 (예외 A · 세트 없음)
  static DetectionResultData figmaZeroSetsPreset() {
    final base = figmaThreeSetsPreset().cards;
    return DetectionResultData(cards: base, sets: const []);
  }
}
