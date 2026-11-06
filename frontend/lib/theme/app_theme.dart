import 'package:flutter/material.dart';

/// Exact Design Tokens extracted from Figma file 'Set' (node-id 0:1).
class SetColors {
  SetColors._();

  // Core Surfaces & Backgrounds
  static const Color bgSlate900 = Color(0xFF0F172A);
  static const Color surfaceSlate800 = Color(0xFF1E293B);
  static const Color borderSlate700 = Color(0xFF334155);
  static const Color glassSlate900 = Color(0xCC0F172A); // rgba(15,23,42,0.80)
  static const Color inactiveDimming = Color(0xB80F172A); // rgba(15,23,42,0.72)

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Accent & SET Connection Palette (01 / Cyan, 02 / Rose, 03 / Amber)
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color cyanTint12 = Color(0x1F06B6D4); // rgba(6,182,212,0.12)

  static const Color roseAccent = Color(0xFFF43F5E);
  static const Color roseTint12 = Color(0x1FF43F5E); // rgba(244,63,94,0.12)

  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberTint12 = Color(0x1FF59E0B); // rgba(245,158,11,0.12)

  static const List<Color> setPalette = [
    cyanAccent,
    roseAccent,
    amberAccent,
  ];

  // Physical Playing Card Tokens
  static const Color cardSurface = Color(0xFFF5F1E8);
  static const Color cardBorder = Color(0xFFDED8CB);
  static const Color symbolPurple = Color(0xFF725197);
  static const Color symbolGreen = Color(0xFF33785B);
  static const Color symbolRed = Color(0xFFB83F58);

  // Tabletop Wood Grain & Scrim Tokens (Figma EL-98ce110f, EL-c2042b87, EL-c5e87964)
  static const Color tabletopBase = Color(0xFF231F1A);
  static const Color tabletopGradStart = Color(0xFF8C8370);
  static const Color tabletopGradMid = Color(0xFF686454);
  static const Color tabletopGradEnd = Color(0xFF847968);
  static const Color woodGrainDark = Color(0x29332E24); // rgba(51, 46, 36, 0.16)
  static const Color woodGrainLight = Color(0x12D9C9A5); // rgba(217, 201, 165, 0.07)
  static const Color plankSeam = Color(0x2B302B24); // rgba(48, 43, 36, 0.17)

  static const LinearGradient tabletopGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tabletopGradStart, tabletopGradMid, tabletopGradEnd],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient headerScrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xF00F172A), // rgba(15, 23, 42, 0.94)
      Color(0xB30F172A), // rgba(15, 23, 42, 0.70)
      Color(0x000F172A), // rgba(15, 23, 42, 0.00)
    ],
    stops: [0.0, 0.72, 1.0],
  );

  static const LinearGradient controlsScrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000F172A), // rgba(15, 23, 42, 0.00)
      Color(0xE60F172A), // rgba(15, 23, 42, 0.90)
      Color(0xFF0F172A), // rgba(15, 23, 42, 1.00)
    ],
    stops: [0.0, 0.35, 1.0],
  );

  static Color setColorForIndex(int index) {
    return setPalette[index % setPalette.length];
  }

  static Color setTintForIndex(int index) {
    return setColorForIndex(index).withOpacity(0.12);
  }
}

class SetTheme {
  SetTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SetColors.bgSlate900,
      colorScheme: const ColorScheme.dark(
        primary: SetColors.cyanAccent,
        secondary: SetColors.amberAccent,
        error: SetColors.roseAccent,
        surface: SetColors.surfaceSlate800,
      ),
      fontFamily: 'Noto Sans KR',
    );
  }
}
