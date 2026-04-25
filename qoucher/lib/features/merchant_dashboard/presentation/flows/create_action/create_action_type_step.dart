import 'package:flutter/material.dart';

class CreateActionTypeStep extends StatelessWidget {
  const CreateActionTypeStep({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final String? selectedType;
  final ValueChanged<String> onSelected;

  static const List<Map<String, String>> actionTypes = [
    {'key': 'deal', 'label': 'Deal'},
    {'key': 'reward', 'label': 'Reward'},
    {'key': 'coupon', 'label': 'Coupon'},
    {'key': 'points_booster', 'label': 'Punkte-Booster'},
    {'key': 'stamp_campaign', 'label': 'Stempelaktion'},
    {'key': 'free_item', 'label': 'Gratisartikel'},
    {'key': 'discount_item', 'label': 'Rabatt auf Artikel'},
    {'key': 'discount_all', 'label': 'Rabatt auf alles'},
    {'key': 'two_for_one', 'label': '2 für 1'},
    {'key': 'two_plus_one', 'label': '2 + 1'},
    {'key': 'buy_x_get_y', 'label': 'Kauf X → Y'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welche Aktion möchtest du starten?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actionTypes.map((type) {
            final key = type['key']!;
            final isActive = selectedType == key;

            return GestureDetector(
              onTap: () => onSelected(key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  type['label']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}