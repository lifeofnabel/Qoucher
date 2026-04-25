import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/core/theme/text_styles.dart';
import 'package:qoucher/core/widgets/app_card.dart';

class AppLoader extends StatelessWidget {
  final String? text;
  final bool centered;
  final bool fullScreen;

  const AppLoader({
    super.key,
    this.text,
    this.centered = true,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              color: AppColors.primaryDark,
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: 14),
            Text(
              text!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: content),
      );
    }

    if (centered) {
      return Center(child: content);
    }

    return content;
  }
}