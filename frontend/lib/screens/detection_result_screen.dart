import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 03: '03  탐지 결과 · 3 SETs' (DetectionResultScreen, 393x852).
class DetectionResultScreen extends StatelessWidget {
  final DetectionResultData result;
  final VoidCallback onRetake;
  final ValueChanged<int> onInspectSet;

  const DetectionResultScreen({
    super.key,
    required this.result,
    required this.onRetake,
    required this.onInspectSet,
  });

  @override
  Widget build(BuildContext context) {
    final setCount = result.setCount;

    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result navigation (345x44): Back icon | Chip / Success ('✨ 3개의 SET 발견!') | More icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SetIconButton(
                    icon: Icons.chevron_left,
                    tooltip: '뒤로 가기',
                    onPressed: onRetake,
                  ),
                  // Chip / Success (123x32, rgba(6,182,212,0.12), stroke #06B6D4)
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SetColors.cyanTint12,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: SetColors.cyanAccent),
                    ),
                    child: Text(
                      '✨ $setCount개의 SET 발견!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SetColors.cyanAccent,
                      ),
                    ),
                  ),
                  SetIconButton(
                    icon: Icons.more_horiz,
                    tooltip: '세트 상세 보기',
                    onPressed: () => onInspectSet(0),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Capture summary ('12장 분석 완료 · 번호로 카드를 확인하세요')
              Text(
                '${result.cardCount}장 분석 완료 · 번호로 카드를 확인하세요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // 3x4 Detected Cards + Valid SET connection triangles
              Expanded(
                child: TabletopBoardWidget(
                  cards: result.cards,
                  activeSets: result.sets,
                  activeSetColors: SetColors.setPalette,
                  showBadges: true,
                ),
              ),
              const SizedBox(height: 12),

              // Set summary section (345x130)
              const Text(
                '세 가지 조합을 찾았어요.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // SET legend (3 Set reference cards: SET 01, SET 02, SET 03)
              Row(
                children: List.generate(
                  result.sets.length.clamp(0, 3),
                  (idx) {
                    final setComb = result.sets[idx];
                    final setColor = SetColors.setColorForIndex(idx);
                    final label = 'SET ${(idx + 1).toString().padLeft(2, '0')}';

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: idx < 2 ? 8.0 : 0.0),
                        child: InkWell(
                          onTap: () => onInspectSet(idx),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: SetColors.glassSlate900,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SetColors.borderSlate700,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: setColor,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Mono',
                                        fontSize: 10,
                                        color: setColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  setComb.formattedReference,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Mono',
                                    fontSize: 10,
                                    color: SetColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Result note
              const Text(
                '연결된 카드의 모양·색상·개수·채움을 비교해보세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Result actions (Secondary '다시 촬영' 124x56 + Primary '세트 하나씩 보기' 213x56)
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
                      label: '세트 하나씩 보기',
                      onPressed: () => onInspectSet(0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
