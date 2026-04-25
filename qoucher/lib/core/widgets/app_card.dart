import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/core/constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool withBorder;
  final bool glassy;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.xl),
    this.onTap,
    this.withBorder = true,
    this.glassy = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: glassy
            ? AppColors.surface.withOpacity(0.9)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        border: withBorder
            ? Border.all(
          color: AppColors.border,
          width: AppSizes.borderRegular,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.9),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        onTap: onTap,
        child: card,
      ),
    );
  }
}