import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../services/set_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 03: '03  탐지 결과 · 세트 존재 여부' (DetectionResultScreen, #8:11187, 393x852).
class DetectionResultScreen extends StatelessWidget {
  final DetectionResultData result;
  final VoidCallback onRetake;
  final ValueChanged<int> onInspectSet;
  final ValueChanged<DetectionResultData>? onResultUpdated;

  const DetectionResultScreen({
    super.key,
    required this.result,
    required this.onRetake,
    required this.onInspectSet,
    this.onResultUpdated,
  });

  void _openSingleCardEditSheet(BuildContext context, int cardIdx) {
    if (cardIdx < 0 || cardIdx >= result.cards.length) return;
    final currentItem = result.cards[cardIdx];
    var numVal = currentItem.card.number.value;
    var shapeVal = currentItem.card.shape.value;
    var colorVal = currentItem.card.color.value;
    var shadingVal = currentItem.card.shading.value;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SetColors.surfaceSlate800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final draftCard =
              SetCard.fromAttributes(numVal, shapeVal, colorVal, shadingVal);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '카드 ${currentItem.displayNumber} 속성 수정',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SetColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: PlayingCardWidget(
                    card: draftCard,
                    badgeNumber: currentItem.displayNumber,
                    highlightColor: SetColors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      label: Text('개수: $numVal개'),
                      onPressed: () =>
                          setModalState(() => numVal = (numVal % 3) + 1),
                    ),
                    ActionChip(
                      label: Text('모양: ${draftCard.shape.koreanLabel}'),
                      onPressed: () =>
                          setModalState(() => shapeVal = (shapeVal % 3) + 1),
                    ),
                    ActionChip(
                      label: Text('색상: ${draftCard.color.koreanLabel}'),
                      onPressed: () =>
                          setModalState(() => colorVal = (colorVal % 3) + 1),
                    ),
                    ActionChip(
                      label: Text('채움: ${draftCard.shading.koreanLabel}'),
                      onPressed: () => setModalState(
                          () => shadingVal = (shadingVal % 3) + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SetPrimaryButton(
                  label: '적용 및 세트 재계산',
                  onPressed: () {
                    final updatedCards =
                        List<DetectedCardItem>.from(result.cards);
                    updatedCards[cardIdx] = DetectedCardItem(
                      index: currentItem.index,
                      card: draftCard,
                    );
                    final solver = const OfflineSetSolver();
                    final newSets = solver.findSets(
                      updatedCards.map((e) => e.card).toList(),
                    );
                    Navigator.of(ctx).pop();
                    onResultUpdated?.call(
                      DetectionResultData(cards: updatedCards, sets: newSets),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: WoodTabletopBackground(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result navigation (#8:11217, 345x44): Back icon | Chip / Success ('✨ 세트가 발견되었어요') | More icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SetIconButton(
                      icon: Icons.chevron_left,
                      tooltip: '뒤로 가기',
                      onPressed: onRetake,
                    ),
                    const SetSuccessChip(
                      label: '✨ 세트가 발견되었어요',
                    ),
                    SetIconButton(
                      icon: Icons.more_horiz,
                      tooltip: '세트 상세 보기',
                      onPressed: () => onInspectSet(0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Capture summary (#8:11216: '12장 분석 완료 · 세트 존재 여부 확인')
                Text(
                  '${result.cardCount}장 분석 완료 · 세트 존재 여부 확인',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SetColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // 3x4 Detected Cards (#8:11230: 01..12 badges & bounding boxes without spoiling SET triangles)
                Expanded(
                  child: TabletopBoardWidget(
                    cards: result.cards,
                    activeSets: const [],
                    showBadges: true,
                    onCardTap: (idx) => _openSingleCardEditSheet(context, idx),
                  ),
                ),
                const SizedBox(height: 20),

                // Set summary section (#8:11197: gap 16px)
                const Text(
                  '세트가 발견되었어요.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SetColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '어떤 카드가 세트인지 다음 화면에서 확인해보세요.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: SetColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Result actions (#8:11191: Secondary '다시 촬영' 124x56 + Primary '세트 조합 보기' fill x 56)
                Row(
                  children: [
                    SizedBox(
                      width: 124,
                      child: SetSecondaryButton(
                        label: '다시 촬영',
                        icon: Icons.refresh,
                        onPressed: onRetake,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SetPrimaryButton(
                        label: '세트 조합 보기',
                        onPressed: () => onInspectSet(0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
