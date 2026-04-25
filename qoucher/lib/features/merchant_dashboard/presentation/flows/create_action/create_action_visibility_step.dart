import 'package:flutter/material.dart';

class CreateActionVisibilityStep extends StatelessWidget {
  const CreateActionVisibilityStep({
    super.key,
    required this.isVisible,
    required this.status,
    required this.onVisibilityChanged,
    required this.onStatusChanged,
  });

  final bool isVisible;
  final String status;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sichtbarkeit & Status',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Öffentlich sichtbar'),
          subtitle: const Text('Auf Shop-Seite / Hauptseite anzeigen'),
          value: isVisible,
          onChanged: onVisibilityChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'draft', child: Text('Draft')),
            DropdownMenuItem(value: 'active', child: Text('Aktiv')),
            DropdownMenuItem(value: 'paused', child: Text('Pausiert')),
          ],
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
        ),
      ],
    );
  }
}