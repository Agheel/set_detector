import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 01: '01  시작 안내' (OnboardingScreen, 393x852).
class OnboardingScreen extends StatelessWidget {
  final VoidCallback onStartPressed;

  const OnboardingScreen({
    super.key,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand Header ('Set Detector', Inter 22px w600)
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: SetColors.cyanTint12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: SetColors.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Set Detector',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: SetColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Three card connection illustration (345x240)
              SizedBox(
                height: 240,
                child: Container(
                  decoration: BoxDecoration(
                    color: SetColors.surfaceSlate800.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: SetColors.borderSlate700.withOpacity(0.5),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Precision grid lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PrecisionGridPainter(),
                        ),
                      ),
                      // 3 Illustrated cards + Neon Connection Lines
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 24,
                          bottom: 36,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PlayingCardWidget(
                              card: SetCard.fromAttributes(1, 3, 3, 1),
                              width: 84,
                              height: 116,
                            ),
                            PlayingCardWidget(
                              card: SetCard.fromAttributes(2, 2, 2, 2),
                              width: 84,
                              height: 116,
                            ),
                            PlayingCardWidget(
                              card: SetCard.fromAttributes(3, 1, 1, 3),
                              width: 84,
                              height: 116,
                            ),
                          ],
                        ),
                      ),
                      // Illustration annotation bar
                      const Positioned(
                        left: 16,
                        right: 16,
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VISION / FOUR ATTRIBUTES',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 10,
                                color: SetColors.textSecondary,
                              ),
                            ),
                            Text(
                              'SET VERIFIED ✓',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: SetColors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Introduction (Main message 29px Bold + Supporting message 14px)
              const Text(
                '카메라를 비추면\nAI가 세트를 즉시 찾아냅니다.',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '복잡한 조합은 AI에게, 발견의 즐거움은 당신에게.',
                style: TextStyle(
                  fontSize: 14,
                  color: SetColors.textSecondary,
                ),
              ),
              const Spacer(),

              // Privacy assurance badge (345x72, #1E293B, radius 16)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SetColors.surfaceSlate800,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: SetColors.cyanAccent,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '촬영된 이미지는 분석 후 즉시 폐기되며 서버에 저장되지 않습니다.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: SetColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Start action (Button / Primary 345x56)
              SetPrimaryButton(
                label: '카메라 권한 허용 및 시작',
                icon: Icons.arrow_forward,
                onPressed: onStartPressed,
              ),
              const SizedBox(height: 12),

              // Permission note
              const Text(
                '카메라 권한은 설정에서 언제든 변경할 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: SetColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrecisionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = SetColors.borderSlate700.withOpacity(0.33)
      ..strokeWidth = 1;

    for (var i = 1; i <= 5; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var j = 1; j <= 3; j++) {
      final y = size.height * (j / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3-color connection lines (Cyan, Rose, Amber)
    final p1 = Offset(size.width * 0.18, size.height * 0.45);
    final p2 = Offset(size.width * 0.50, size.height * 0.36);
    final p3 = Offset(size.width * 0.82, size.height * 0.45);

    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = SetColors.cyanAccent
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      p2,
      p3,
      Paint()
        ..color = SetColors.roseAccent
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      p1,
      p3,
      Paint()
        ..color = SetColors.amberAccent
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
