import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.primary,
    onPrimary: AppColors.black,

    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryDeep,

    secondary: AppColors.black,
    onSecondary: AppColors.white,

    secondaryContainer: AppColors.backgroundDeep,
    onSecondaryContainer: AppColors.black,

    tertiary: AppColors.red,
    onTertiary: AppColors.white,

    tertiaryContainer: AppColors.accentSoft,
    onTertiaryContainer: AppColors.red,

    error: AppColors.error,
    onError: AppColors.white,

    errorContainer: AppColors.accentSoft,
    onErrorContainer: AppColors.red,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,

    surfaceContainerHighest: AppColors.backgroundDeep,
    onSurfaceVariant: AppColors.textSecondary,

    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,

    shadow: AppColors.shadow,
    scrim: Colors.black54,

    inverseSurface: AppColors.black,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.amber,
  );
}