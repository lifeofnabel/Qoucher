import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/core/constants/app_sizes.dart';
import 'package:qoucher/core/theme/color_scheme.dart';
import 'package:qoucher/core/theme/text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColorScheme.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: AppTextStyles.textTheme,
    );

    return base.copyWith(
      canvasColor: AppColors.background,
      splashColor: AppColors.amber.withOpacity(0.14),
      highlightColor: AppColors.primaryLight.withOpacity(0.45),
      dividerColor: AppColors.border,
      shadowColor: AppColors.shadow,
      disabledColor: AppColors.textMuted.withOpacity(0.42),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.black,
          size: 23,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          side: const BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.black.withOpacity(0.24),
          disabledForegroundColor: AppColors.white.withOpacity(0.7),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          side: const BorderSide(
            color: AppColors.black,
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.black,
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.lg,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w800,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppSizes.borderRegular,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppSizes.borderRegular,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          borderSide: const BorderSide(
            color: AppColors.black,
            width: AppSizes.borderFocused,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSizes.borderRegular,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSizes.borderFocused,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySoft,
        disabledColor: AppColors.backgroundDeep,
        selectedColor: AppColors.black,
        secondarySelectedColor: AppColors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
        brightness: Brightness.light,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.black,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl),
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        side: const BorderSide(
          color: AppColors.borderStrong,
          width: 1.5,
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return AppColors.textMuted;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return AppColors.primaryLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return AppColors.border;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.black,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        iconColor: AppColors.black,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w900,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        ),
      ),
    );
  }

  static BoxDecoration glassyCardDecoration = BoxDecoration(
    color: AppColors.surface.withOpacity(0.92),
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.border,
      width: AppSizes.borderRegular,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 30,
        offset: Offset(0, 16),
      ),
    ],
  );

  static BoxDecoration softPanelDecoration = BoxDecoration(
    color: AppColors.primarySoft,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.border,
      width: AppSizes.borderThin,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );

  static BoxDecoration darkPanelDecoration = BoxDecoration(
    gradient: AppColors.darkGradient,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.black,
      width: AppSizes.borderThin,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 30,
        offset: Offset(0, 16),
      ),
    ],
  );

  static BoxDecoration premiumPanelDecoration = BoxDecoration(
    gradient: AppColors.premiumGradient,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.borderStrong,
      width: AppSizes.borderThin,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 32,
        offset: Offset(0, 16),
      ),
    ],
  );

  static BoxDecoration dangerPanelDecoration = BoxDecoration(
    color: AppColors.accentSoft,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.red.withOpacity(0.25),
      width: AppSizes.borderThin,
    ),
  );
}