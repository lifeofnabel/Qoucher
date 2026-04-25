import 'package:flutter/material.dart';
import 'create_action_flow_data.dart';

class CreateActionPreviewStep extends StatelessWidget {
  const CreateActionPreviewStep({
    super.key,
    required this.data,
  });

  final CreateActionFlowData data;

  @override
  Widget build(BuildContext context) {
    Widget infoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vorschau',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                infoRow('Typ', data.type ?? '-'),
                infoRow('Titel', data.title ?? '-'),
                infoRow('Untertitel', data.subtitle ?? '-'),
                infoRow('Beschreibung', data.description ?? '-'),
                infoRow('Bild', data.imageUrl ?? '-'),
                infoRow('Artikel-ID', data.linkedItemId ?? '-'),
                infoRow('Status', data.status),
                infoRow('Sichtbar', data.isVisible ? 'Ja' : 'Nein'),
                infoRow('Start', data.startsAt?.toString() ?? '-'),
                infoRow('Ende', data.endsAt?.toString() ?? 'Unendlich'),
                infoRow('Rules', data.rules.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}