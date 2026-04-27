import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Main Tiffany Colors
  static const Color primary = Color(0xFF00BFA6);
  static const Color primaryDark = Color(0xFF007F73);
  static const Color primaryDeep = Color(0xFF004E48);
  static const Color primaryLight = Color(0xFFD8FFF8);
  static const Color primarySoft = Color(0xFFEFFFFC);

  // Accent Colors
  static const Color accent = Color(0xFFFFD166);
  static const Color accentSoft = Color(0xFFFFF4D6);

  // Backgrounds
  static const Color background = Color(0xFFF3FFFD);
  static const Color backgroundDeep = Color(0xFFE4FAF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFEFFFFC);
  static const Color inputFill = Color(0xFFF7FFFD);

  // Text
  static const Color textPrimary = Color(0xFF082C2A);
  static const Color textSecondary = Color(0xFF355F5A);
  static const Color textMuted = Color(0xFF7E9A96);

  // Border / Shadow
  static const Color border = Color(0xFFC9F2EC);
  static const Color borderStrong = Color(0xFF8BE4DA);
  static const Color shadow = Color(0x26007F73);

  // Status
  static const Color success = Color(0xFF17B26A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFE5484D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D9C0),
      Color(0xFF00BFA6),
      Color(0xFF007F73),
    ],
  );

  static const LinearGradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEFFFFC),
      Color(0xFFF8FFFE),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFEFFFFC),
      Color(0xFFD8FFF8),
    ],
  );

  static const LinearGradient darkTiffanyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF004E48),
      Color(0xFF007F73),
      Color(0xFF00BFA6),
    ],
  );
}