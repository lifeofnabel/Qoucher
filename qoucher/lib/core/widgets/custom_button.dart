import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/core/constants/app_sizes.dart';
import 'package:qoucher/core/theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeightLg,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: AppColors.border,
              width: AppSizes.borderRegular,
            ),
            backgroundColor: Colors.white.withOpacity(0.72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
          ),
          child: _buildChild(textColor: AppColors.primaryDark),
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : AppColors.darkTiffanyGradient,
        color: isDisabled ? AppColors.primaryDark.withOpacity(0.35) : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: isDisabled
            ? null
            : [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        child: _buildChild(textColor: Colors.white),
      ),
    );
  }

  Widget _buildChild({required Color textColor}) {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: Colors.white,
        ),
      );
    }

    if (icon == null) {
      return Text(
        text,
        style: AppTextStyles.buttonLarge.copyWith(color: textColor),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: textColor,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.buttonLarge.copyWith(color: textColor),
        ),
      ],
    );
  }
}