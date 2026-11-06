import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 05B: '05B  예외 B · 촬영 품질' (QualityWarningScreen, #8:11854, 393x852).
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
          // Blurred & dimmed low-light tabletop background (#8:11892: filter blur(1.5px))
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Opacity(
                opacity: 0.45,
                child: WoodTabletopBackground(
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
                  // Quality navigation (#8:11880, 345x44): Back icon | '촬영 품질 확인' | Active Flash icon
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

                  // Quality flags (#8:11873: '흔들림 감지' #F43F5E & '빛이 부족해요' #F59E0B)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SetStatusChip(
                        label: '흔들림 감지',
                        icon: Icons.center_focus_weak,
                        textColor: SetColors.roseAccent,
                        backgroundColor: SetColors.roseTint12,
                        borderColor: SetColors.roseAccent,
                      ),
                      SizedBox(width: 8),
                      SetStatusChip(
                        label: '빛이 부족해요',
                        icon: Icons.wb_sunny_outlined,
                        textColor: SetColors.amberAccent,
                        backgroundColor: SetColors.amberTint12,
                        borderColor: SetColors.amberAccent,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Focus warning reticle (#8:11869, 112x112 with Warning registration corners #8:11870)
                  Center(
                    child: SizedBox(
                      width: 112,
                      height: 112,
                      child: CustomPaint(
                        painter: const CardRegistrationCornersPainter(
                          color: SetColors.roseAccent,
                          strokeWidth: 2.0,
                          cornerLength: 22.0,
                          radius: 16.0,
                        ),
                        child: Center(
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
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Capture quality tooltip (#8:11862: 345x144, #1E293B, stroke #F43F5E, radius 16 + Tooltip pointer #8:11863)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: SetColors.surfaceSlate800,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: SetColors.roseAccent,
                            width: 1.0,
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
                                height: 1.8,
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
                      // Tooltip pointer (#8:11863: 16x8 at top center)
                      Positioned(
                        top: -8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CustomPaint(
                            size: const Size(16, 8),
                            painter: _TooltipPointerPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Retry action (#8:11858: '다시 촬영하기')
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

class _TooltipPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = SetColors.roseAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
