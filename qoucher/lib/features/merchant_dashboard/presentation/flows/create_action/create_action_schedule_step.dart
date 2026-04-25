import 'package:flutter/material.dart';

class CreateActionScheduleStep extends StatelessWidget {
  const CreateActionScheduleStep({
    super.key,
    required this.startsAt,
    required this.endsAt,
    required this.onChanged,
  });

  final DateTime? startsAt;
  final DateTime? endsAt;
  final void Function(DateTime? startsAt, DateTime? endsAt) onChanged;

  Future<void> _pickStart(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startsAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    onChanged(picked, endsAt);
  }

  Future<void> _pickEnd(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: endsAt ?? startsAt ?? now,
      firstDate: startsAt ?? DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    onChanged(startsAt, picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    String formatDate(DateTime? date) {
      if (date == null) return 'Nicht gesetzt';
      return '${date.day}.${date.month}.${date.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zeitraum',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Startdatum'),
          subtitle: Text(formatDate(startsAt)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickStart(context),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enddatum'),
          subtitle: Text(formatDate(endsAt)),
          trailing: const Icon(Icons.event_busy_outlined),
          onTap: () => _pickEnd(context),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => onChanged(startsAt, null),
          child: const Text('Enddatum entfernen / unendlich'),
        ),
      ],
    );
  }
}