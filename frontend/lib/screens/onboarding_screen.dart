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

              // Three card connection illustration (#8:10930, 345x240)
              SizedBox(
                height: 240,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final scaleX = w / 345.0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Precision grid lines (#8:10963..#8:10972)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PrecisionGridPainter(scaleX: scaleX),
                          ),
                        ),
                        // Card 1 (#8:10958: x:0, y:48, 88x124)
                        Positioned(
                          left: 0,
                          top: 48,
                          child: PlayingCardWidget(
                            card: SetCard.fromAttributes(1, 3, 3, 1),
                            width: 88,
                            height: 124,
                          ),
                        ),
                        // Card 2 (#8:10948: x:128, y:0, 88x124)
                        Positioned(
                          left: 128 * scaleX,
                          top: 0,
                          child: PlayingCardWidget(
                            card: SetCard.fromAttributes(2, 2, 2, 2),
                            width: 88,
                            height: 124,
                          ),
                        ),
                        // Card 3 (#8:10937: x:256, y:80, 88x124)
                        Positioned(
                          left: 256 * scaleX,
                          top: 80,
                          child: PlayingCardWidget(
                            card: SetCard.fromAttributes(3, 1, 1, 3),
                            width: 88,
                            height: 124,
                          ),
                        ),
                        // Cyan / Rose / Amber connection lines (#8:10934..#8:10936)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _IllustrationConnectionPainter(
                                scaleX: scaleX,
                              ),
                            ),
                          ),
                        ),
                        // Illustration annotation bar (#8:10931: y:220)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Introduction (#8:10927: Main message 29px Bold + Supporting message 14px)
              const Text(
                '카메라를 비추면\nAI가 세트를 즉시 찾아냅니다.',
                style: TextStyle(
                  fontSize: 29,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '복잡한 조합은 AI에게, 발견의 즐거움은 당신에게.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
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
  final double scaleX;

  const _PrecisionGridPainter({this.scaleX = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = SetColors.borderSlate700.withOpacity(0.33)
      ..strokeWidth = 1;

    // Exact Figma vertical lines: x = 0, 64, 128, 192, 256, 320
    for (final rawX in const [0.0, 64.0, 128.0, 192.0, 256.0, 320.0]) {
      final x = rawX * scaleX;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Exact Figma horizontal lines: y = 16, 80, 144, 208
    for (final y in const [16.0, 80.0, 144.0, 208.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PrecisionGridPainter oldDelegate) =>
      oldDelegate.scaleX != scaleX;
}

class _IllustrationConnectionPainter extends CustomPainter {
  final double scaleX;

  const _IllustrationConnectionPainter({this.scaleX = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Card centers in Figma #8:10930: (44, 110), (172, 62), (300, 142)
    final p1 = Offset(44 * scaleX, 110);
    final p2 = Offset(172 * scaleX, 62);
    final p3 = Offset(300 * scaleX, 142);

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

    final anchorBorder = Paint()
      ..color = SetColors.bgSlate900
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final entry in [
      MapEntry(p1, SetColors.cyanAccent),
      MapEntry(p2, SetColors.roseAccent),
      MapEntry(p3, SetColors.amberAccent),
    ]) {
      canvas.drawCircle(entry.key, 4.0, Paint()..color = entry.value);
      canvas.drawCircle(entry.key, 4.0, anchorBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _IllustrationConnectionPainter oldDelegate) =>
      oldDelegate.scaleX != scaleX;
}
