import 'package:flutter/material.dart';

import 'package:qoucher/core/constants/app_colors.dart';

class StampPreviewSheet extends StatelessWidget {
  const StampPreviewSheet({
    super.key,
    required this.title,
    required this.description,
    required this.rewardTitle,
    required this.stampCount,
    required this.collectedStamps,
    required this.primaryColor,
    required this.softColor,
    required this.lookMode,
    required this.stampShape,
    required this.icon,
    required this.fontStyle,
  });

  final String title;
  final String description;
  final String rewardTitle;
  final int stampCount;
  final int collectedStamps;
  final Color primaryColor;
  final Color softColor;
  final String lookMode;
  final String stampShape;
  final IconData icon;
  final String fontStyle;

  bool get isBoldLook => lookMode == 'Bold';
  bool get isMinimalLook => lookMode == 'Minimal';
  bool get isPremiumLook => lookMode == 'Premium';

  double get safeProgress {
    if (stampCount <= 0) return 0;
    return (collectedStamps / stampCount).clamp(0.0, 1.0);
  }

  bool get isLightPrimary => primaryColor.computeLuminance() > 0.45;

  Color get cardBackground {
    if (isBoldLook || isPremiumLook) return primaryColor;
    if (isMinimalLook) return AppColors.surface;
    return softColor;
  }

  Color get mainTextColor {
    if (isBoldLook || isPremiumLook) {
      return isLightPrimary ? AppColors.black : AppColors.white;
    }
    return AppColors.black;
  }

  Color get subTextColor {
    if (isBoldLook || isPremiumLook) {
      return isLightPrimary ? AppColors.textSecondary : AppColors.white.withOpacity(0.84);
    }
    return AppColors.textMuted;
  }

  Color get filledStampColor {
    if (isBoldLook || isPremiumLook) return AppColors.white;
    if (isMinimalLook) return AppColors.black;
    return primaryColor;
  }

  Color get filledStampIconColor {
    if (isBoldLook || isPremiumLook) return primaryColor;
    return AppColors.white;
  }

  Color get emptyStampColor {
    if (isBoldLook || isPremiumLook) return AppColors.white.withOpacity(0.18);
    if (isMinimalLook) return AppColors.inputFill;
    return AppColors.white;
  }

  Color get progressColor {
    if (isBoldLook || isPremiumLook) return AppColors.white;
    if (isMinimalLook) return AppColors.black;
    return primaryColor;
  }

  Color get progressBackground {
    if (isBoldLook || isPremiumLook) return AppColors.white.withOpacity(0.18);
    return AppColors.white;
  }

  BoxDecoration get cardDecoration {
    if (isPremiumLook) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            Color.lerp(primaryColor, AppColors.black, 0.32) ?? primaryColor,
            Color.lerp(primaryColor, AppColors.white, 0.12) ?? primaryColor,
          ],
        ),
        border: Border.all(
          color: AppColors.white.withOpacity(0.18),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 32,
            offset: const Offset(0, 18),
            color: primaryColor.withOpacity(0.26),
          ),
        ],
      );
    }

    if (isMinimalLook) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: AppColors.surface,
        border: Border.all(color: AppColors.black, width: 1.5),
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(36),
      color: cardBackground,
      border: Border.all(
        color: primaryColor.withOpacity(0.35),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 26,
          offset: const Offset(0, 14),
          color: primaryColor.withOpacity(isBoldLook ? 0.22 : 0.08),
        ),
      ],
    );
  }

  TextStyle smartTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    switch (fontStyle) {
      case 'Elegant':
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color,
          fontFamily: 'serif',
          letterSpacing: 0.25,
        );
      case 'Playful':
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w900,
          color: color,
          letterSpacing: 0.05,
        );
      case 'Modern':
      default:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w800,
          color: color,
          letterSpacing: -0.35,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Kunden-Vorschau',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 30,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'So sieht der Kunde seine Karte im späteren Loyalty-Bereich.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _customerStampCard(context),
                const SizedBox(height: 16),
                _customerActionPreview(),
                const SizedBox(height: 14),
                _hintBox(
                  'Vorschau ist nur optisch. Echte Stempel kommen später durch Scan, Artikel-Regel oder Betragsregel.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customerStampCard(BuildContext context) {
    final completed = collectedStamps >= stampCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(),
          const SizedBox(height: 18),
          Text(
            description,
            style: TextStyle(
              height: 1.35,
              color: subTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _progressBlock(),
          const SizedBox(height: 20),
          _responsiveStampGrid(),
          const SizedBox(height: 22),
          _rewardBox(completed),
        ],
      ),
    );
  }

  Widget _cardHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: (isBoldLook || isPremiumLook)
              ? AppColors.white.withOpacity(0.18)
              : AppColors.white,
          child: Icon(
            icon,
            color: (isBoldLook || isPremiumLook) ? AppColors.white : primaryColor,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: smartTextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$lookMode · $fontStyle',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: (isBoldLook || isPremiumLook)
                ? AppColors.white.withOpacity(0.18)
                : AppColors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$collectedStamps/$stampCount',
            style: TextStyle(
              color: (isBoldLook || isPremiumLook) ? AppColors.white : AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _progressBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: safeProgress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(99),
          color: progressColor,
          backgroundColor: progressBackground,
        ),
        const SizedBox(height: 10),
        Text(
          '$collectedStamps von $stampCount Stempeln gesammelt',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: mainTextColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _responsiveStampGrid() {
    if (stampCount <= 5) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stampCount, (index) {
          return _stampBubble(
            filled: index < collectedStamps,
            size: 52,
          );
        }),
      );
    }

    return Wrap(
      spacing: 11,
      runSpacing: 11,
      children: List.generate(stampCount, (index) {
        return _stampBubble(
          filled: index < collectedStamps,
          size: 50,
        );
      }),
    );
  }

  Widget _stampBubble({
    required bool filled,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: stampShape == 'Kreis' ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: stampShape == 'Kreis'
            ? null
            : BorderRadius.circular(stampShape == 'Quadrat' ? 12 : 18),
        color: filled ? filledStampColor : emptyStampColor,
        border: Border.all(
          color: (isBoldLook || isPremiumLook)
              ? AppColors.white.withOpacity(0.42)
              : primaryColor.withOpacity(0.50),
          width: 1.7,
        ),
      ),
      child: Icon(
        _stampIcon(),
        color: filled ? filledStampIconColor : primaryColor,
        size: size * 0.50,
      ),
    );
  }

  IconData _stampIcon() {
    switch (stampShape) {
      case 'Herz':
        return Icons.favorite;
      case 'Stern':
        return Icons.star;
      case 'Quadrat':
        return Icons.check_box_outline_blank;
      case 'Kreis':
      default:
        return Icons.check;
    }
  }

  Widget _rewardBox(bool completed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: (isBoldLook || isPremiumLook)
            ? AppColors.white.withOpacity(0.16)
            : AppColors.white.withOpacity(0.72),
        border: Border.all(
          color: (isBoldLook || isPremiumLook)
              ? AppColors.white.withOpacity(0.28)
              : primaryColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.celebration_rounded : Icons.card_giftcard_rounded,
            color: (isBoldLook || isPremiumLook) ? AppColors.white : primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed ? 'Belohnung freigeschaltet' : 'Belohnung',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rewardTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: mainTextColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerActionPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Später beim Kunden',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Kunde aktiviert Karte, sammelt Stempel und sieht Rewards.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.inputFill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.black,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
