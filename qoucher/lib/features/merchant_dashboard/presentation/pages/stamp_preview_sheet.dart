import 'package:flutter/material.dart';

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

  Color get cardBackground => isBoldLook ? primaryColor : softColor;

  Color get mainTextColor {
    if (!isBoldLook) return const Color(0xFF111827);

    final isLightBold =
        primaryColor.computeLuminance() > 0.45;

    return isLightBold ? const Color(0xFF111827) : Colors.white;
  }

  Color get subTextColor {
    if (!isBoldLook) return const Color(0xFF4B5563);

    final isLightBold =
        primaryColor.computeLuminance() > 0.45;

    return isLightBold
        ? const Color(0xFF374151)
        : Colors.white.withOpacity(0.86);
  }

  Color get filledStampColor => isBoldLook ? Colors.white : primaryColor;
  Color get filledStampIconColor => isBoldLook ? primaryColor : Colors.white;
  Color get emptyStampColor =>
      isBoldLook ? Colors.white.withOpacity(0.20) : Colors.white;

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
          letterSpacing: 0.3,
        );
      case 'Playful':
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w900,
          color: color,
          letterSpacing: 0.1,
        );
      case 'Modern':
      default:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w800,
          color: color,
          letterSpacing: -0.2,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = collectedStamps / stampCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kunden-Vorschau',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'So sieht der Kunde seine Karte.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _customerStampCard(context, progress),
            const SizedBox(height: 18),
            _hintBox(
              context,
              'Bei 3–5 Stempeln wird die Karte über die ganze Breite gefüllt.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerStampCard(BuildContext context, double progress) {
    final completed = collectedStamps >= stampCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        color: cardBackground,
        border: Border.all(
          color: primaryColor.withOpacity(0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: primaryColor.withOpacity(isBoldLook ? 0.22 : 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(context),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.35,
              color: subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            color: isBoldLook ? Colors.white : primaryColor,
            backgroundColor:
            isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            '$collectedStamps / $stampCount Stempel gesammelt',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 20),
          _responsiveStampGrid(),
          const SizedBox(height: 22),
          _rewardBox(completed),
        ],
      ),
    );
  }

  Widget _cardHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 31,
          backgroundColor:
          isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
          child: Icon(
            icon,
            color: isBoldLook ? Colors.white : primaryColor,
            size: 33,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: smartTextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$lookMode · $fontStyle',
                style: TextStyle(
                  color: subTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
          color: isBoldLook
              ? Colors.white.withOpacity(0.42)
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
        borderRadius: BorderRadius.circular(22),
        color: isBoldLook
            ? Colors.white.withOpacity(0.16)
            : Colors.white.withOpacity(0.72),
        border: Border.all(
          color: isBoldLook
              ? Colors.white.withOpacity(0.28)
              : primaryColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.celebration_outlined
                : Icons.card_giftcard_outlined,
            color: isBoldLook ? Colors.white : primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              completed
                  ? 'Belohnung freigeschaltet: $rewardTitle'
                  : 'Belohnung: $rewardTitle',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: mainTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBox(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}