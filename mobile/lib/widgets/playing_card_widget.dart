import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';

/// Renders a single SET Playing Card matching Figma 'Playing card' node (#F5F1E8, stroke #DED8CB, r=7).
class PlayingCardWidget extends StatelessWidget {
  final SetCard card;
  final double width;
  final double height;
  final String? badgeNumber;
  final Color? highlightColor;
  final bool isDimmed;
  final VoidCallback? onTap;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.width = 88.0,
    this.height = 80.0,
    this.badgeNumber,
    this.highlightColor,
    this.isDimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlightColor ??
        (badgeNumber != null
            ? SetColors.textPrimary.withOpacity(0.70)
            : Colors.transparent);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width + 16,
        height: height + 16,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Bounding box frame (96x88, radius 10)
            if (badgeNumber != null || highlightColor != null)
              Container(
                width: width + 8,
                height: height + 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: borderColor,
                    width: highlightColor != null ? 2.2 : 1.2,
                  ),
                ),
              ),

            // Physical Playing Card (88x80 or 88x124, #F5F1E8, border #DED8CB, radius 7)
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: SetColors.cardSurface,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: SetColors.cardBorder, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  card.number.value,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: CustomPaint(
                      size: const Size(16, 36),
                      painter: _CardSymbolPainter(
                        shape: card.shape,
                        color: card.color.color,
                        shading: card.shading,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Card number badge (24x24, radius 6)
            if (badgeNumber != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlightColor ?? SetColors.bgSlate900,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: highlightColor ??
                          SetColors.textPrimary.withOpacity(0.40),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badgeNumber!,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: highlightColor != null
                          ? SetColors.bgSlate900
                          : SetColors.textPrimary,
                    ),
                  ),
                ),
              ),

            // Inactive card dimming overlay (Figma 'Inactive card dimming' rgba(15,23,42,0.72))
            if (isDimmed)
              Container(
                width: width + 12,
                height: height + 12,
                decoration: BoxDecoration(
                  color: SetColors.inactiveDimming,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardSymbolPainter extends CustomPainter {
  final CardShape shape;
  final Color color;
  final CardShading shading;

  const _CardSymbolPainter({
    required this.shape,
    required this.color,
    required this.shading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildShapePath(size);

    if (shading == CardShading.solid) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    } else if (shading == CardShading.striped) {
      canvas.save();
      canvas.clipPath(path);
      final stripePaint = Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (double y = 3; y < size.height; y += 4.5) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
      }
      canvas.restore();
    }

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  Path _buildShapePath(Size size) {
    final path = Path();
    switch (shape) {
      case CardShape.oval:
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(1, 2, size.width - 2, size.height - 4),
            Radius.circular(size.width / 2),
          ),
        );
        break;
      case CardShape.diamond:
        path.moveTo(size.width / 2, 1);
        path.lineTo(size.width - 1, size.height / 2);
        path.lineTo(size.width / 2, size.height - 1);
        path.lineTo(1, size.height / 2);
        path.close();
        break;
      case CardShape.squiggle:
        final w = size.width;
        final h = size.height;
        path.moveTo(w * 0.25, h * 0.12);
        path.cubicTo(w * 0.85, h * 0.0, w * 0.95, h * 0.35, w * 0.65, h * 0.52);
        path.cubicTo(w * 0.35, h * 0.68, w * 0.90, h * 0.85, w * 0.72, h * 0.92);
        path.cubicTo(w * 0.20, h * 1.0, w * 0.05, h * 0.65, w * 0.35, h * 0.48);
        path.cubicTo(w * 0.65, h * 0.32, w * 0.10, h * 0.20, w * 0.25, h * 0.12);
        path.close();
        break;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _CardSymbolPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.shading != shading;
  }
}

/// CustomPainter for Figma 'Valid SET connection' (SET area highlight + Neon glow + Center triangle + Anchors).
class ValidSetConnectionPainter extends CustomPainter {
  final List<List<Offset>> triangles;
  final List<Color> colors;

  const ValidSetConnectionPainter({
    required this.triangles,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < triangles.length; i++) {
      final pts = triangles[i];
      if (pts.length < 3) continue;
      final color = colors[i % colors.length];

      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();

      // 1. SET area highlight fill
      final fillPaint = Paint()
        ..color = color.withOpacity(0.14)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // 2. Neon connection glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.35)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);

      // 3. SET center triangle line
      final strokePaint = Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);

      // 4. Card center anchors (8x8 ellipse with #0F172A stroke)
      final anchorFill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final anchorBorder = Paint()
        ..color = SetColors.bgSlate900
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final pt in pts) {
        canvas.drawCircle(pt, 4.5, anchorFill);
        canvas.drawCircle(pt, 4.5, anchorBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ValidSetConnectionPainter oldDelegate) {
    return oldDelegate.triangles != triangles || oldDelegate.colors != colors;
  }
}

/// Interactive 3x4 Tabletop Card Grid with optional registration corners & SET connection overlay.
class TabletopBoardWidget extends StatelessWidget {
  final List<DetectedCardItem> cards;
  final List<SetCombinationItem> activeSets;
  final List<Color> activeSetColors;
  final Set<int>? focusedCardIndices;
  final Color? focusedHighlightColor;
  final bool showRegistrationGuide;
  final bool showBadges;
  final ValueChanged<int>? onCardTap;

  const TabletopBoardWidget({
    super.key,
    required this.cards,
    this.activeSets = const [],
    this.activeSetColors = SetColors.setPalette,
    this.focusedCardIndices,
    this.focusedHighlightColor,
    this.showRegistrationGuide = false,
    this.showBadges = true,
    this.onCardTap,
  });

  Offset _cardCenterForIndex(int index, double boardWidth, double boardHeight) {
    // Figma cards are arranged in 3 columns x 4 rows (indices 0..11)
    final col = index % 3;
    final row = index ~/ 3;
    final cellW = boardWidth / 3;
    final cellH = boardHeight / 4;
    return Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardW = constraints.maxWidth;
        final boardH = constraints.maxHeight;

        final triangles = <List<Offset>>[];
        for (final comb in activeSets) {
          triangles.add(
            comb.indices
                .map((idx) => _cardCenterForIndex(idx, boardW, boardH))
                .toList(),
          );
        }

        return Stack(
          children: [
            // 3x4 Card Grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: boardH / 4,
              ),
              itemCount: cards.length.clamp(0, 12),
              itemBuilder: (context, idx) {
                final item = cards[idx];
                final isFocused = focusedCardIndices == null ||
                    focusedCardIndices!.contains(item.index);
                final isDimmed =
                    focusedCardIndices != null && !isFocused;

                return Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (showRegistrationGuide)
                        Container(
                          width: 96,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: SetColors.textPrimary.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      PlayingCardWidget(
                        card: item.card,
                        badgeNumber: showBadges ? item.displayNumber : null,
                        highlightColor:
                            (focusedCardIndices != null && isFocused)
                                ? focusedHighlightColor
                                : null,
                        isDimmed: isDimmed,
                        onTap: onCardTap != null
                            ? () => onCardTap!(item.index)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Valid SET Connection Overlay (Triangles + Anchors)
            if (triangles.isNotEmpty)
              IgnorePointer(
                child: CustomPaint(
                  size: Size(boardW, boardH),
                  painter: ValidSetConnectionPainter(
                    triangles: triangles,
                    colors: activeSetColors,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Reusable Figma Circular Icon Button (44x44, rgba(15,23,42,0.80), stroke #334155).
class SetIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final String? tooltip;

  const SetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = SetColors.textPrimary,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SetColors.glassSlate900,
            shape: BoxShape.circle,
            border: Border.all(color: SetColors.borderSlate700, width: 1),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

/// Reusable Figma Primary Button (height 56, #06B6D4, radius 16, text #0F172A Bold).
class SetPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const SetPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SetColors.cyanAccent,
          foregroundColor: SetColors.bgSlate900,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: SetColors.bgSlate900),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: SetColors.bgSlate900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Figma Secondary Button (height 56, #1E293B, stroke #334155, radius 16).
class SetSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const SetSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: SetColors.surfaceSlate800,
          foregroundColor: SetColors.textPrimary,
          side: const BorderSide(color: SetColors.borderSlate700, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: SetColors.textPrimary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: SetColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
