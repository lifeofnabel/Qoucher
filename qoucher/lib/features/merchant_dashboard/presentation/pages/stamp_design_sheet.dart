import 'package:flutter/material.dart';

import 'package:qoucher/core/constants/app_colors.dart';

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

  final List<_StampTheme> themes = const [
    _StampTheme(
      name: 'Noir',
      label: 'Noir',
      primary: Color(0xFF050505),
      soft: Color(0xFFF3F1EA),
      accent: Color(0xFFFFFFFF),
    ),
    _StampTheme(
      name: 'Cream',
      label: 'Cream',
      primary: Color(0xFFC79A3B),
      soft: Color(0xFFFFF2D2),
      accent: Color(0xFF5C3900),
    ),
    _StampTheme(
      name: 'Levant',
      label: 'Levant',
      primary: Color(0xFFA80000),
      soft: Color(0xFFFFE7D8),
      accent: Color(0xFFFFD166),
    ),
    _StampTheme(
      name: 'Fresh',
      label: 'Fresh',
      primary: Color(0xFF168A46),
      soft: Color(0xFFE4F8EA),
      accent: Color(0xFFFFFFFF),
    ),
    _StampTheme(
      name: 'Ocean',
      label: 'Ocean',
      primary: Color(0xFF1D4ED8),
      soft: Color(0xFFE3ECFF),
      accent: Color(0xFFFFFFFF),
    ),
    _StampTheme(
      name: 'Rose',
      label: 'Rose',
      primary: Color(0xFFE87EA1),
      soft: Color(0xFFFFE4EC),
      accent: Color(0xFF3A101E),
    ),
    _StampTheme(
      name: 'Beer',
      label: 'Beer',
      primary: Color(0xFFB66A00),
      soft: Color(0xFFFFE6B5),
      accent: Color(0xFF2B1600),
    ),
    _StampTheme(
      name: 'Clean',
      label: 'Clean',
      primary: Color(0xFF00A6A6),
      soft: Color(0xFFE6FFFF),
      accent: Color(0xFF003E3E),
    ),
  ];

  final List<String> lookModes = const [
    'Soft',
    'Bold',
    'Minimal',
    'Premium',
  ];

  final List<String> shapes = const [
    'Kreis',
    'Quadrat',
    'Herz',
    'Stern',
  ];

  final List<String> fonts = const [
    'Modern',
    'Elegant',
    'Playful',
  ];

  final List<_IconOption> icons = const [
    _IconOption(Icons.local_cafe_outlined, 'Kaffee'),
    _IconOption(Icons.restaurant_menu_outlined, 'Food'),
    _IconOption(Icons.local_pizza_outlined, 'Pizza'),
    _IconOption(Icons.lunch_dining_outlined, 'Burger'),
    _IconOption(Icons.kebab_dining_outlined, 'Kebab'),
    _IconOption(Icons.icecream_outlined, 'Dessert'),
    _IconOption(Icons.local_bar_outlined, 'Bar'),
    _IconOption(Icons.sports_bar_outlined, 'Bier'),
    _IconOption(Icons.local_drink_outlined, 'Drink'),
    _IconOption(Icons.content_cut_outlined, 'Barber'),
    _IconOption(Icons.spa_outlined, 'Beauty'),
    _IconOption(Icons.soap_outlined, 'Hygiene'),
    _IconOption(Icons.clean_hands_outlined, 'Clean'),
    _IconOption(Icons.storefront_outlined, 'Store'),
    _IconOption(Icons.card_giftcard_outlined, 'Gift'),
    _IconOption(Icons.local_fire_department_outlined, 'Hot'),
    _IconOption(Icons.favorite_border, 'Heart'),
    _IconOption(Icons.star_border, 'Star'),
  ];

  @override
  void initState() {
    super.initState();

    theme = _safeTheme(widget.selectedTheme);
    lookMode = _safeValue(widget.selectedLookMode, lookModes, 'Soft');
    shape = _safeValue(widget.selectedShape, shapes, 'Kreis');
    icon = widget.selectedIcon;
    fontStyle = _safeValue(widget.selectedFontStyle, fonts, 'Modern');
  }

  String _safeTheme(String value) {
    final exists = themes.any((item) => item.name == value);
    return exists ? value : 'Noir';
  }

  String _safeValue(String value, List<String> allowed, String fallback) {
    return allowed.contains(value) ? value : fallback;
  }

  _StampTheme get activeTheme {
    return themes.firstWhere(
      (item) => item.name == theme,
      orElse: () => themes.first,
    );
  }

  bool get isBoldLook => lookMode == 'Bold';
  bool get isMinimalLook => lookMode == 'Minimal';
  bool get isPremiumLook => lookMode == 'Premium';

  Color get primaryColor => activeTheme.primary;
  Color get softColor => activeTheme.soft;
  Color get accentColor => activeTheme.accent;

  Color get cardBackground {
    if (isBoldLook || isPremiumLook) return primaryColor;
    if (isMinimalLook) return AppColors.surface;
    return softColor;
  }

  Color get mainTextColor {
    if (isBoldLook || isPremiumLook) {
      if (theme == 'Cream' || theme == 'Rose' || theme == 'Beer') {
        return AppColors.black;
      }
      return AppColors.white;
    }

    return AppColors.black;
  }

  Color get subTextColor {
    if (isBoldLook || isPremiumLook) {
      if (theme == 'Cream' || theme == 'Rose' || theme == 'Beer') {
        return AppColors.textSecondary;
      }
      return AppColors.white.withOpacity(0.82);
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

  BoxDecoration get previewDecoration {
    if (isPremiumLook) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            Color.lerp(primaryColor, AppColors.black, 0.38) ?? primaryColor,
            Color.lerp(primaryColor, accentColor, 0.28) ?? primaryColor,
          ],
        ),
        border: Border.all(color: accentColor.withOpacity(0.38)),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 16),
            color: primaryColor.withOpacity(0.22),
          ),
        ],
      );
    }

    if (isMinimalLook) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.surface,
        border: Border.all(color: AppColors.black, width: 1.4),
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      color: cardBackground,
      border: Border.all(color: primaryColor.withOpacity(0.32)),
      boxShadow: [
        BoxShadow(
          blurRadius: 22,
          offset: const Offset(0, 12),
          color: primaryColor.withOpacity(isBoldLook ? 0.20 : 0.08),
        ),
      ],
    );
  }

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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
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
                  'Design Studio',
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
                  'Wähle Farbe, Look, Form, Icon und Schrift. Die Karte zeigt sofort, wie sie später wirkt.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _designPreview(),
                const SizedBox(height: 22),
                _sectionTitle('Theme'),
                const SizedBox(height: 10),
                _themeGrid(),
                const SizedBox(height: 20),
                _sectionTitle('Look'),
                const SizedBox(height: 10),
                _optionGrid(
                  items: lookModes,
                  selected: lookMode,
                  subtitles: const {
                    'Soft': 'hell & ruhig',
                    'Bold': 'laut & stark',
                    'Minimal': 'clean & schwarz',
                    'Premium': 'tief & glänzend',
                  },
                  onSelected: (value) => setState(() => lookMode = value),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Stempelform'),
                const SizedBox(height: 10),
                _shapeGrid(),
                const SizedBox(height: 20),
                _sectionTitle('Schrift'),
                const SizedBox(height: 10),
                _optionGrid(
                  items: fonts,
                  selected: fontStyle,
                  subtitles: const {
                    'Modern': 'klar',
                    'Elegant': 'seriös',
                    'Playful': 'locker',
                  },
                  onSelected: (value) => setState(() => fontStyle = value),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Icon'),
                const SizedBox(height: 10),
                _iconGrid(),
                const SizedBox(height: 24),
                _applyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _designPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: previewDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: (isBoldLook || isPremiumLook)
                    ? AppColors.white.withOpacity(0.18)
                    : AppColors.white,
                child: Icon(
                  icon,
                  color: (isBoldLook || isPremiumLook)
                      ? AppColors.white
                      : primaryColor,
                  size: 33,
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
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: mainTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$theme · $lookMode · $fontStyle',
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
                  '3/5',
                  style: TextStyle(
                    color: (isBoldLook || isPremiumLook)
                        ? AppColors.white
                        : AppColors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Sammle Stempel und sichere dir deine Belohnung.',
            style: TextStyle(
              color: subTextColor,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            color: (isBoldLook || isPremiumLook) ? AppColors.white : primaryColor,
            backgroundColor: (isBoldLook || isPremiumLook)
                ? AppColors.white.withOpacity(0.18)
                : AppColors.white,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return _stampBubble(filled: index < 3);
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
          color: (isBoldLook || isPremiumLook)
              ? AppColors.white.withOpacity(0.42)
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
    );
  }

  Widget _themeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: themes.map((item) {
        final selected = theme == item.name;

        return GestureDetector(
          onTap: () => setState(() => theme = item.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 104,
            height: 86,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.black : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _colorDot(item.primary),
                    const SizedBox(width: 5),
                    _colorDot(item.soft),
                    const SizedBox(width: 5),
                    _colorDot(item.accent),
                  ],
                ),
                const Spacer(),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.black.withOpacity(0.12)),
      ),
    );
  }

  Widget _optionGrid({
    required List<String> items,
    required String selected,
    required Map<String, String> subtitles,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selected == item;

        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 158,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.black : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.black : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitles[item] ?? '',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textDisabled
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _shapeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: shapes.map((item) {
        final selected = shape == item;

        return GestureDetector(
          onTap: () => setState(() => shape = item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.black : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _shapeIcon(item),
                  color: selected ? AppColors.white : AppColors.black,
                  size: 28,
                ),
                const SizedBox(height: 7),
                Text(
                  item,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _shapeIcon(String item) {
    switch (item) {
      case 'Herz':
        return Icons.favorite_rounded;
      case 'Stern':
        return Icons.star_rounded;
      case 'Quadrat':
        return Icons.crop_square_rounded;
      case 'Kreis':
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _iconGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: icons.map((item) {
        final selected = icon == item.icon;

        return GestureDetector(
          onTap: () => setState(() => icon = item.icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.black : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: selected ? AppColors.white : AppColors.black,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.textDisabled : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _applyButton() {
    return GestureDetector(
      onTap: _apply,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Design übernehmen',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StampTheme {
  const _StampTheme({
    required this.name,
    required this.label,
    required this.primary,
    required this.soft,
    required this.accent,
  });

  final String name;
  final String label;
  final Color primary;
  final Color soft;
  final Color accent;
}

class _IconOption {
  const _IconOption(this.icon, this.label);

  final IconData icon;
  final String label;
}
