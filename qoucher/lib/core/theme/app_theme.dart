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
      splashColor: AppColors.primary.withOpacity(0.08),
      highlightColor: AppColors.primaryLight.withOpacity(0.35),
      dividerColor: AppColors.border,
      shadowColor: AppColors.shadow,
      disabledColor: AppColors.textMuted.withOpacity(0.45),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface.withOpacity(0.96),
        elevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.primaryLight.withOpacity(0.25),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          backgroundColor: Colors.white.withOpacity(0.72),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: AppSizes.borderRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primaryDark,
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
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
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
            color: AppColors.primary,
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
        backgroundColor: AppColors.primaryLight.withOpacity(0.55),
        disabledColor: AppColors.primaryLight.withOpacity(0.25),
        selectedColor: AppColors.primaryDark,
        secondarySelectedColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryDark,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
        brightness: Brightness.light,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
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
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
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
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textMuted;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.primaryLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        iconColor: AppColors.primaryDark,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleSmall,
        subtitleTextStyle: AppTextStyles.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        ),
      ),
    );
  }

  static BoxDecoration glassyCardDecoration = BoxDecoration(
    color: AppColors.surface.withOpacity(0.88),
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.border,
      width: AppSizes.borderRegular,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 34,
        offset: Offset(0, 18),
      ),
    ],
  );

  static BoxDecoration softPanelDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 30,
        offset: Offset(0, 14),
      ),
    ],
  );

  static BoxDecoration premiumPanelDecoration = BoxDecoration(
    gradient: AppColors.premiumGradient,
    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
    border: Border.all(
      color: AppColors.border,
      width: AppSizes.borderThin,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 28,
        offset: Offset(0, 14),
      ),
    ],
  );
}