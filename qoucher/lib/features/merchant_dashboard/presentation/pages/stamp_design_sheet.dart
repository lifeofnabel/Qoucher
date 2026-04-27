import 'package:flutter/material.dart';

class StampDesignSheet extends StatefulWidget {
  const StampDesignSheet({
    super.key,
    required this.selectedTheme,
    required this.selectedLookMode,
    required this.selectedShape,
    required this.selectedIcon,
    required this.selectedFontStyle,
    required this.onApply,
  });

  final String selectedTheme;
  final String selectedLookMode;
  final String selectedShape;
  final IconData selectedIcon;
  final String selectedFontStyle;

  final void Function({
  required String theme,
  required String lookMode,
  required String shape,
  required IconData icon,
  required String fontStyle,
  }) onApply;

  @override
  State<StampDesignSheet> createState() => _StampDesignSheetState();
}

class _StampDesignSheetState extends State<StampDesignSheet> {
  late String theme;
  late String lookMode;
  late String shape;
  late IconData icon;
  late String fontStyle;

  final List<String> themes = [
    'Tiffany',
    'Gold',
    'Dark',
    'Rose',
    'Fresh',
    'Ocean',
  ];

  final List<String> lookModes = [
    'Soft',
    'Bold',
  ];

  final List<String> shapes = [
    'Kreis',
    'Quadrat',
    'Herz',
    'Stern',
  ];

  final List<String> fonts = [
    'Modern',
    'Elegant',
    'Playful',
  ];

  final List<IconData> icons = const [
    Icons.local_cafe_outlined,
    Icons.restaurant_menu_outlined,
    Icons.local_pizza_outlined,
    Icons.lunch_dining_outlined,
    Icons.icecream_outlined,
    Icons.content_cut_outlined,
    Icons.spa_outlined,
    Icons.storefront_outlined,
    Icons.favorite_border,
    Icons.star_border,
  ];

  @override
  void initState() {
    super.initState();
    theme = widget.selectedTheme;
    lookMode = widget.selectedLookMode;
    shape = widget.selectedShape;
    icon = widget.selectedIcon;
    fontStyle = widget.selectedFontStyle;
  }

  bool get isBoldLook => lookMode == 'Bold';

  Color get primaryColor {
    switch (theme) {
      case 'Gold':
        return const Color(0xFFD6A23D);
      case 'Dark':
        return const Color(0xFF111827);
      case 'Rose':
        return const Color(0xFFE87EA1);
      case 'Fresh':
        return const Color(0xFF4CAF50);
      case 'Ocean':
        return const Color(0xFF2563EB);
      case 'Tiffany':
      default:
        return const Color(0xFF00BFA6);
    }
  }

  Color get softColor {
    switch (theme) {
      case 'Gold':
        return const Color(0xFFFFF3CF);
      case 'Dark':
        return const Color(0xFFE5E7EB);
      case 'Rose':
        return const Color(0xFFFFE4EC);
      case 'Fresh':
        return const Color(0xFFE5FFE9);
      case 'Ocean':
        return const Color(0xFFE0ECFF);
      case 'Tiffany':
      default:
        return const Color(0xFFE5FFFA);
    }
  }

  Color get cardBackground => isBoldLook ? primaryColor : softColor;

  Color get mainTextColor {
    if (!isBoldLook) return const Color(0xFF111827);
    if (theme == 'Gold' || theme == 'Rose') return const Color(0xFF111827);
    return Colors.white;
  }

  Color get subTextColor {
    if (!isBoldLook) return const Color(0xFF4B5563);
    if (theme == 'Gold' || theme == 'Rose') return const Color(0xFF374151);
    return Colors.white.withOpacity(0.86);
  }

  Color get filledStampColor => isBoldLook ? Colors.white : primaryColor;
  Color get filledStampIconColor => isBoldLook ? primaryColor : Colors.white;
  Color get emptyStampColor =>
      isBoldLook ? Colors.white.withOpacity(0.20) : Colors.white;

  TextStyle previewTextStyle({
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

  void _apply() {
    widget.onApply(
      theme: theme,
      lookMode: lookMode,
      shape: shape,
      icon: icon,
      fontStyle: fontStyle,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Design anpassen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Einfach wählen. Karte sieht direkt anders aus.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _designPreview(),

            const SizedBox(height: 22),

            _title('Theme'),
            _chips(
              items: themes,
              selected: theme,
              onSelected: (value) => setState(() => theme = value),
            ),

            const SizedBox(height: 18),

            _title('Look'),
            _chips(
              items: lookModes,
              selected: lookMode,
              onSelected: (value) => setState(() => lookMode = value),
            ),

            const SizedBox(height: 18),

            _title('Stempelform'),
            _chips(
              items: shapes,
              selected: shape,
              onSelected: (value) => setState(() => shape = value),
            ),

            const SizedBox(height: 18),

            _title('Icon'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: icons.map((item) {
                final selected = icon == item;

                return InkWell(
                  onTap: () => setState(() => icon = item),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: selected
                          ? primaryColor.withOpacity(0.16)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: selected ? primaryColor : Colors.transparent,
                        width: 1.6,
                      ),
                    ),
                    child: Icon(
                      item,
                      color: selected ? primaryColor : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check),
                label: const Text('Design übernehmen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _designPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: cardBackground,
        border: Border.all(color: primaryColor.withOpacity(0.32)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: primaryColor.withOpacity(isBoldLook ? 0.20 : 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
                child: Icon(
                  icon,
                  color: isBoldLook ? Colors.white : primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treuekarte',
                      style: previewTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: mainTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$theme · $lookMode · $fontStyle',
                      style: TextStyle(
                        color: subTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            color: isBoldLook ? Colors.white : primaryColor,
            backgroundColor:
            isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final filled = index < 3;

              return _stampBubble(filled: filled);
            }),
          ),
        ],
      ),
    );
  }

  Widget _stampBubble({required bool filled}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: shape == 'Kreis' ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == 'Kreis'
            ? null
            : BorderRadius.circular(shape == 'Quadrat' ? 12 : 18),
        color: filled ? filledStampColor : emptyStampColor,
        border: Border.all(
          color: isBoldLook
              ? Colors.white.withOpacity(0.42)
              : primaryColor.withOpacity(0.50),
          width: 1.6,
        ),
      ),
      child: Icon(
        _stampIcon(),
        color: filled ? filledStampIconColor : primaryColor,
        size: 25,
      ),
    );
  }

  IconData _stampIcon() {
    switch (shape) {
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

  Widget _title(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _chips({
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return ChoiceChip(
            label: Text(item),
            selected: selected == item,
            onSelected: (_) => onSelected(item),
          );
        }).toList(),
      ),
    );
  }
}