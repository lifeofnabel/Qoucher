import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'NexaProText';

  static TextStyle get displayLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: -1.35,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w900,
    height: 1.08,
    letterSpacing: -1.05,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 29,
    fontWeight: FontWeight.w900,
    height: 1.12,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.16,
    letterSpacing: -0.45,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    height: 1.22,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.55,
    letterSpacing: -0.05,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: -0.03,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: 0.05,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
  );

  static TextStyle get buttonLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w900,
    height: 1,
    letterSpacing: 0.05,
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    height: 1,
    letterSpacing: 0.05,
  );

  static TextStyle get caption => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: 0.05,
    color: AppColors.textMuted,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}