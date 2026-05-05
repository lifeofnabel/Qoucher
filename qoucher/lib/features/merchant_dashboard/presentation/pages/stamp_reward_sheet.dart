import 'package:flutter/material.dart';

import 'package:qoucher/core/constants/app_colors.dart';

class StampRewardSheet extends StatefulWidget {
  const StampRewardSheet({
    super.key,
    required this.rewardTitle,
    required this.rewardDescription,
    required this.autoRewardEnabled,
    required this.onApply,
  });

  final String rewardTitle;
  final String rewardDescription;
  final bool autoRewardEnabled;

  final void Function({
    required String title,
    required String description,
    required bool autoReward,
  }) onApply;

  @override
  State<StampRewardSheet> createState() => _StampRewardSheetState();
}

class _StampRewardSheetState extends State<StampRewardSheet> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late bool autoReward;

  final List<_RewardTemplate> rewardTemplates = const [
    _RewardTemplate(
      title: 'Gratis Kaffee',
      description: 'Nach voller Karte erhält der Kunde einen gratis Kaffee.',
      icon: Icons.local_cafe_rounded,
    ),
    _RewardTemplate(
      title: 'Gratis Wrap',
      description: 'Nach voller Karte erhält der Kunde einen gratis Wrap.',
      icon: Icons.lunch_dining_rounded,
    ),
    _RewardTemplate(
      title: 'Gratis Getränk',
      description: 'Nach voller Karte erhält der Kunde ein gratis Getränk.',
      icon: Icons.local_drink_rounded,
    ),
    _RewardTemplate(
      title: '10% Rabatt',
      description: 'Nach voller Karte erhält der Kunde 10% Rabatt auf den nächsten Einkauf.',
      icon: Icons.percent_rounded,
    ),
    _RewardTemplate(
      title: 'Upgrade gratis',
      description: 'Nach voller Karte erhält der Kunde ein kostenloses Upgrade.',
      icon: Icons.upgrade_rounded,
    ),
    _RewardTemplate(
      title: 'Überraschung',
      description: 'Nach voller Karte erhält der Kunde eine Überraschung an der Kasse.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.rewardTitle);
    descriptionController = TextEditingController(text: widget.rewardDescription);
    autoReward = widget.autoRewardEnabled;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String get titlePreview {
    final value = titleController.text.trim();
    return value.isEmpty ? 'Belohnung' : value;
  }

  String get descriptionPreview {
    final value = descriptionController.text.trim();
    return value.isEmpty
        ? 'Der Kunde erhält eine Belohnung nach voller Karte.'
        : value;
  }

  void _applyTemplate(_RewardTemplate template) {
    setState(() {
      titleController.text = template.title;
      descriptionController.text = template.description;
    });
  }

  void _apply() {
    widget.onApply(
      title: titlePreview,
      description: descriptionPreview,
      autoReward: autoReward,
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
                  'Reward Studio',
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
                  'Definiere, was Kunden bekommen, wenn die Stempelkarte voll ist.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _rewardPreview(),
                const SizedBox(height: 20),
                _sectionTitle('Schnell-Vorlagen'),
                const SizedBox(height: 10),
                _templateGrid(),
                const SizedBox(height: 20),
                _sectionTitle('Reward Text'),
                const SizedBox(height: 10),
                _inputCard(),
                const SizedBox(height: 16),
                _autoRewardBox(),
                const SizedBox(height: 16),
                _infoBox(
                  'Empfehlung: Auto-Reward aktiv lassen. Dann versteht der Kunde sofort: Karte voll = Belohnung bereit.',
                ),
                const SizedBox(height: 20),
                _applyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rewardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belohnung',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  titlePreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  autoReward ? 'Automatisch vorbereitet' : 'Manuell an der Kasse',
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12.5,
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

  Widget _templateGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: rewardTemplates.map((template) {
        final selected = titleController.text.trim() == template.title;

        return GestureDetector(
          onTap: () => _applyTemplate(template),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 154,
            padding: const EdgeInsets.all(13),
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
                Icon(
                  template.icon,
                  color: selected ? AppColors.white : AppColors.black,
                  size: 24,
                ),
                const SizedBox(height: 10),
                Text(
                  template.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '1 Klick Vorlage',
                  style: TextStyle(
                    color: selected ? AppColors.textDisabled : AppColors.textMuted,
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

  Widget _inputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _sheetInput(
            controller: titleController,
            hint: 'z. B. Gratis Kaffee',
            icon: Icons.card_giftcard_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _sheetInput(
            controller: descriptionController,
            hint: 'Was bekommt der Kunde genau?',
            icon: Icons.notes_rounded,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _sheetInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _autoRewardBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: autoReward ? AppColors.black : AppColors.inputFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: autoReward ? AppColors.black : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: autoReward ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Automatisch auslösen',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  autoReward
                      ? 'Karte voll: Belohnung wird automatisch vorbereitet.'
                      : 'Kasse entscheidet manuell, ob Reward gilt.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: autoReward,
            activeColor: AppColors.black,
            onChanged: (value) => setState(() => autoReward = value),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text) {
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
            Icons.lightbulb_outline_rounded,
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
          'Belohnung übernehmen',
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

class _RewardTemplate {
  const _RewardTemplate({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
