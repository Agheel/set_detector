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
                    color: Color(0x45000000), // rgba(0, 0, 0, 0.27)
                    blurRadius: 8,
                    offset: Offset(2, 5),
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

            // Inactive card dimming overlay (Figma 'Inactive card dimming' 104x96, rgba(15,23,42,0.72), r=10)
            if (isDimmed)
              Container(
                width: width + 16,
                height: height + 16,
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
          final validIndices =
              comb.indices.where((idx) => idx >= 0 && idx < 12).toList();
          if (validIndices.length == 3) {
            triangles.add(
              validIndices
                  .map((idx) => _cardCenterForIndex(idx, boardW, boardH))
                  .toList(),
            );
          }
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

                if (showRegistrationGuide) {
                  return Center(
                    child: SizedBox(
                      width: 88,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 80,
                            decoration: BoxDecoration(
                              color: SetColors.bgSlate900.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: SetColors.textPrimary.withOpacity(0.28),
                                width: 1.0,
                              ),
                            ),
                          ),
                          CustomPaint(
                            size: const Size(88, 80),
                            painter: CardRegistrationCornersPainter(
                              color: SetColors.cyanAccent.withOpacity(0.85),
                              strokeWidth: 1.8,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: 7,
                            child: Text(
                              item.displayNumber,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: SetColors.textPrimary.withOpacity(0.55),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            size: 12,
                            color: SetColors.textPrimary.withOpacity(0.35),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: PlayingCardWidget(
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

/// Figma Component #8:12314: 'Button / Shutter' (80x80 ring stroke 3px, 64x64 face, 8x8 cyan dot).
class SetShutterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SetShutterButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: SetColors.textPrimary,
            width: 3.0,
          ),
        ),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: SetColors.textPrimary,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: SetColors.cyanAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma Component #8:12315: 'Chip / Success' (height 32, padding 0 12, rgba(6,182,212,0.12), stroke #06B6D4 0.6px).
class SetSuccessChip extends StatelessWidget {
  final String label;

  const SetSuccessChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SetColors.cyanTint12,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SetColors.cyanAccent, width: 0.6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: SetColors.cyanAccent,
        ),
      ),
    );
  }
}

/// Figma Component #8:12316 & #8:12317: 'Chip / Condition' & 'Chip / Warning'.
class SetStatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color textColor;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const SetStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.textColor = SetColors.textPrimary,
    this.backgroundColor = SetColors.surfaceSlate800,
    this.borderColor,
    this.borderRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.6)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma Component #8:12319: 'Card registration corners' corner bracket painter.
class CardRegistrationCornersPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  const CardRegistrationCornersPainter({
    this.color = const Color(0x80F8FAFC),
    this.strokeWidth = 1.3,
    this.cornerLength = 14.0,
    this.radius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final c = cornerLength;
    final r = radius;

    // Top-left corner
    final tl = Path()
      ..moveTo(0, c)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(c, 0);
    canvas.drawPath(tl, paint);

    // Top-right corner
    final tr = Path()
      ..moveTo(w - c, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, c);
    canvas.drawPath(tr, paint);

    // Bottom-left corner
    final bl = Path()
      ..moveTo(0, h - c)
      ..lineTo(0, h - r)
      ..quadraticBezierTo(0, h, r, h)
      ..lineTo(c, h);
    canvas.drawPath(bl, paint);

    // Bottom-right corner
    final br = Path()
      ..moveTo(w - c, h)
      ..lineTo(w - r, h)
      ..quadraticBezierTo(w, h, w, h - r)
      ..lineTo(w, h - c);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant CardRegistrationCornersPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Figma 'Captured tabletop / Editable cards' wood-grain background with Header & Controls contrast scrims.
class WoodTabletopBackground extends StatelessWidget {
  final Widget child;

  const WoodTabletopBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Tabletop Linear Gradient (EL-98ce110f)
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: SetColors.tabletopGradient,
            ),
            child: CustomPaint(
              painter: _WoodGrainPainter(),
            ),
          ),
        ),
        // 2. Header contrast scrim (EL-c2042b87: height 182)
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 182,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: SetColors.headerScrimGradient,
              ),
            ),
          ),
        ),
        // 3. Controls contrast scrim (EL-c5e87964: height 282)
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 282,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: SetColors.controlsScrimGradient,
              ),
            ),
          ),
        ),
        // 4. Foreground content
        child,
      ],
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkGrain = Paint()
      ..color = SetColors.woodGrainDark
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final lightGrain = Paint()
      ..color = SetColors.woodGrainLight
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final seamPaint = Paint()
      ..color = SetColors.plankSeam
      ..strokeWidth = 1.0;

    // Vertical wood grain lines spaced ~19px apart as in Figma EL-1f8fa0e7..EL-5c07bab9
    for (var i = 0; i < 22; i++) {
      final x = (i * 19.0) % size.width;
      final paint = (i % 3 == 0) ? darkGrain : lightGrain;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Plank seams at x = 133/393 and x = 328/393 (EL-ee9663d7, EL-34dcae18)
    canvas.drawLine(
      Offset(size.width * (133 / 393), 0),
      Offset(size.width * (133 / 393), size.height),
      seamPaint,
    );
    canvas.drawLine(
      Offset(size.width * (328 / 393), 0),
      Offset(size.width * (328 / 393), size.height),
      seamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
