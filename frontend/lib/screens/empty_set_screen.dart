import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 05: '05  예외 A · 세트 없음' (EmptySetScreen, 393x852).
class EmptySetScreen extends StatelessWidget {
  final DetectionResultData result;
  final VoidCallback onRetakeWithMoreCards;

  const EmptySetScreen({
    super.key,
    required this.result,
    required this.onRetakeWithMoreCards,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Empty result navigation (345x44): Back icon | '분석 완료' | '0 SET'
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SetIconButton(
                    icon: Icons.chevron_left,
                    tooltip: '뒤로 가기',
                    onPressed: onRetakeWithMoreCards,
                  ),
                  const Text(
                    '분석 완료',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: SetColors.textPrimary,
                    ),
                  ),
                  const Text(
                    '0 SET',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: 13,
                      color: SetColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Analysis summary
              Text(
                '${result.cardCount}장 인식 완료 · 가능한 조합을 모두 확인했어요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // 3x4 Detected Cards (0 SET connections)
              Expanded(
                child: TabletopBoardWidget(
                  cards: result.cards,
                  activeSets: const [],
                  showBadges: true,
                ),
              ),
              const SizedBox(height: 12),

              // No SET toast (345x88, #1E293B, stroke #334155, radius 16)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SetColors.surfaceSlate800,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SetColors.borderSlate700),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: SetColors.cyanTint12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.layers_outlined,
                        color: SetColors.cyanAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '현재 세트가 없습니다. 카드 3장을 더 놓으세요.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SetColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Next step instruction
              const Text(
                '추가한 카드까지 한 화면에 담아주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Retake action ('카드 추가 후 다시 촬영')
              SetPrimaryButton(
                label: '카드 추가 후 다시 촬영',
                icon: Icons.camera_alt_outlined,
                onPressed: onRetakeWithMoreCards,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
