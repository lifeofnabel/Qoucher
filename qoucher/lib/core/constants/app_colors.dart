import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand
  static const Color black = Color(0xFF050401);
  static const Color white = Color(0xFFFAF7EF);
  static const Color amber = Color(0xFFE89A00);
  static const Color red = Color(0xFFE11925);

  // Primary
  static const Color primary = amber;
  static const Color primaryDark = Color(0xFFB87500);
  static const Color primaryDeep = Color(0xFF5C3900);
  static const Color primaryLight = Color(0xFFFFD36A);
  static const Color primarySoft = Color(0xFFFFE2A3);

  // Accent / Danger
  static const Color accent = red;
  static const Color accentDark = Color(0xFFB5121B);
  static const Color accentSoft = Color(0xFFFFC7CC);

  // Backgrounds
  static const Color background = Color(0xFFF2E7D2);
  static const Color backgroundDeep = Color(0xFFE5D2AF);
  static const Color surface = Color(0xFFFFF8EA);
  static const Color surfaceStrong = Color(0xFFFFEDC2);
  static const Color surfaceDark = Color(0xFF12100B);
  static const Color surfaceTint = Color(0xFFFFD36A);
  static const Color inputFill = Color(0xFFF8E8C6);

  // Text
  static const Color textPrimary = Color(0xFF050401);
  static const Color textSecondary = Color(0xFF2E2518);
  static const Color textMuted = Color(0xFF6E604A);
  static const Color textDisabled = Color(0xFF9B8D75);
  static const Color textOnDark = Color(0xFFFAF7EF);

  // Borders / Lines
  static const Color border = Color(0xFFC8A96A);
  static const Color borderStrong = Color(0xFF8F6B24);
  static const Color divider = Color(0xFFD6B978);

  // Shadows
  static const Color shadow = Color(0x33050401);
  static const Color shadowStrong = Color(0x52050401);

  // Status
  static const Color success = Color(0xFF168A46);
  static const Color successSoft = Color(0xFFCDEFD9);

  static const Color warning = amber;
  static const Color warningSoft = Color(0xFFFFD98A);

  static const Color error = red;
  static const Color errorSoft = Color(0xFFFFC7CC);

  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSoft = Color(0xFFC7D7FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE89A00),
      Color(0xFFFFB30F),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF050401),
      Color(0xFF19140B),
    ],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF050401),
      Color(0xFF2B1D06),
      Color(0xFFE89A00),
    ],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE11925),
      Color(0xFFFF3B45),
    ],
  );
}