import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';

class CustomerHistoryTile extends StatelessWidget {
  const CustomerHistoryTile({
    super.key,
    required this.scan,
  });

  final MerchantScanModel scan;

  @override
  Widget build(BuildContext context) {
    final createdAt = scan.createdAt;
    final dateText = createdAt == null
        ? '-'
        : '${createdAt.day}.${createdAt.month}.${createdAt.year} • '
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        title: Text(
          scan.type,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Betrag: ${scan.amount ?? '-'} | '
                'Punkte: ${scan.pointsAdded ?? '-'}\n'
                'Kommentar: ${scan.comment ?? '-'}\n'
                '$dateText',
          ),
        ),
        isThreeLine: true,
        leading: const Icon(Icons.history),
      ),
    );
  }
}