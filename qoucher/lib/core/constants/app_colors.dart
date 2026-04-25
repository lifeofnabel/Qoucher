import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF7FCF5);
  static const Color surface = Colors.white;

  static const Color primaryLight = Color(0xFFD9F2D0);
  static const Color primary = Color(0xFF8BCF95);
  static const Color primaryDark = Color(0xFF244D2C);

  static const Color secondary = Color(0xFFA8E6B0);
  static const Color accent = Color(0xFF6DBB7A);

  static const Color textPrimary = Color(0xFF244D2C);
  static const Color textSecondary = Color(0xFF4F6F55);
  static const Color textMuted = Color(0xFF7C9782);

  static const Color border = Color(0xFFD9F2D0);
  static const Color inputFill = Color(0xFFF9FDF8);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE6A700);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  static const Color shadow = Color(0x14244D2C);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFD9F2D0),
      Color(0xFF8BCF95),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGreenGradient = LinearGradient(
    colors: [
      Color(0xFF2F5E37),
      Color(0xFF244D2C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}