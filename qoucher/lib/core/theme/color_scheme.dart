import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.primary,
    onPrimary: Colors.white,

    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDeep,

    secondary: AppColors.accent,
    onSecondary: AppColors.primaryDeep,

    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.primaryDeep,

    tertiary: AppColors.primaryDark,
    onTertiary: Colors.white,

    error: AppColors.error,
    onError: Colors.white,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,

    surfaceContainerHighest: AppColors.primarySoft,
    onSurfaceVariant: AppColors.textSecondary,

    outline: AppColors.border,
    outlineVariant: AppColors.borderStrong,

    shadow: AppColors.shadow,
    scrim: Colors.black54,

    inverseSurface: AppColors.primaryDeep,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryLight,
  );
}