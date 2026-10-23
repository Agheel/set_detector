import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 05B: '05B  예외 B · 촬영 품질' (QualityWarningScreen, 393x852).
class QualityWarningScreen extends StatelessWidget {
  final VoidCallback onRetryCapture;

  const QualityWarningScreen({
    super.key,
    required this.onRetryCapture,
  });

  @override
  Widget build(BuildContext context) {
    final cards = DetectionResultData.figmaZeroSetsPreset().cards;

    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: Stack(
        children: [
          // Dimmed low-light tabletop background
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 120,
                ),
                child: TabletopBoardWidget(
                  cards: cards,
                  showBadges: false,
                ),
              ),
            ),
          ),

          // Low light exposure scrim (rgba(0,0,0,0.40))
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.40),
            ),
          ),

          // Foreground UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quality navigation (345x44): Back icon | '촬영 품질 확인' | Active Flash icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SetIconButton(
                        icon: Icons.chevron_left,
                        tooltip: '뒤로 가기',
                        onPressed: onRetryCapture,
                      ),
                      const Text(
                        '촬영 품질 확인',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: SetColors.textPrimary,
                        ),
                      ),
                      SetIconButton(
                        icon: Icons.flash_on,
                        iconColor: SetColors.cyanAccent,
                        tooltip: '플래시 켜기',
                        onPressed: onRetryCapture,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quality flags ('흔들림 감지' #F43F5E & '빛이 부족해요' #F59E0B)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Chip / Condition ('흔들림 감지')
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: SetColors.roseTint12,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: SetColors.roseAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.center_focus_weak,
                              size: 14,
                              color: SetColors.roseAccent,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '흔들림 감지',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SetColors.roseAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Chip / Warning ('빛이 부족해요')
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: SetColors.amberTint12,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: SetColors.amberAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 14,
                              color: SetColors.amberAccent,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '빛이 부족해요',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SetColors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Focus warning reticle (112x112)
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: SetColors.roseAccent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: SetColors.glassSlate900,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: SetColors.roseAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Capture quality tooltip (345x144, #1E293B, stroke #F43F5E, radius 16)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SetColors.surfaceSlate800,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: SetColors.roseAccent,
                        width: 1.2,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.center_focus_weak,
                              size: 18,
                              color: SetColors.roseAccent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '화면이 흐리고 어두워요',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: SetColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '렌즈를 닦고 밝은 곳에서 촬영해주세요.\n카메라를 잠시 고정하면 더 잘 인식해요.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: SetColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '카드를 정확히 읽기 위해 분석을 멈췄어요.',
                          style: TextStyle(
                            fontSize: 11,
                            color: SetColors.roseAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Retry action ('다시 촬영하기')
                  SetPrimaryButton(
                    label: '다시 촬영하기',
                    icon: Icons.refresh,
                    onPressed: onRetryCapture,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
