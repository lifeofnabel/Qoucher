import 'package:flutter/material.dart';

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

  final List<String> rewardTemplates = [
    'Gratis Kaffee',
    'Gratis Wrap',
    '10% Rabatt',
    'Gratis Getränk',
    'Upgrade gratis',
    'Überraschung',
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.rewardTitle);
    descriptionController =
        TextEditingController(text: widget.rewardDescription);
    autoReward = widget.autoRewardEnabled;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _applyTemplate(String value) {
    setState(() {
      titleController.text = value;
      descriptionController.text = 'Nach voller Karte erhält der Kunde: $value.';
    });
  }

  void _apply() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    widget.onApply(
      title: title.isEmpty ? 'Belohnung' : title,
      description: description.isEmpty
          ? 'Der Kunde erhält eine Belohnung nach voller Karte.'
          : description,
      autoReward: autoReward,
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
              'Belohnung einstellen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kurz, klar, kassentauglich.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _templateBox(),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Belohnung',
                hintText: 'z. B. Gratis Kaffee',
                prefixIcon: const Icon(Icons.card_giftcard_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Beschreibung',
                hintText: 'Was bekommt der Kunde genau?',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 14),

            _autoRewardBox(),

            const SizedBox(height: 18),

            _infoBox(
              context,
              'Empfehlung: Auto-Reward aktiv lassen. Dann wirkt die Karte für Kunden einfacher und direkter.',
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check),
                label: const Text('Belohnung übernehmen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _templateBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schnell-Vorlagen',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rewardTemplates.map((item) {
              return ActionChip(
                label: Text(item),
                onPressed: () => _applyTemplate(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _autoRewardBox() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.12),
        ),
      ),
      child: SwitchListTile(
        value: autoReward,
        onChanged: (value) => setState(() => autoReward = value),
        title: const Text(
          'Automatisch auslösen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          autoReward
              ? 'Wenn die Karte voll ist, wird die Belohnung automatisch vorbereitet.'
              : 'Kasse entscheidet manuell, wann die Belohnung gilt.',
        ),
      ),
    );
  }

  Widget _infoBox(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.amber.withOpacity(0.12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}