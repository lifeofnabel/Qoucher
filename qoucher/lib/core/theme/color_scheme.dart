import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.primary,
    onSecondary: AppColors.primaryDark,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );
}