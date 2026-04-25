import 'package:flutter/material.dart';

class MerchantStatusChip extends StatelessWidget {
  const MerchantStatusChip({
    super.key,
    required this.label,
  });

  final String label;

  Color _backgroundColor(BuildContext context) {
    switch (label.toLowerCase()) {
      case 'active':
      case 'aktiv':
        return Colors.green.withOpacity(0.12);
      case 'paused':
      case 'pausiert':
        return Colors.orange.withOpacity(0.12);
      case 'archived':
      case 'archiv':
      case 'archived_actions':
        return Colors.grey.withOpacity(0.18);
      case 'draft':
        return Colors.blue.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  Color _textColor(BuildContext context) {
    switch (label.toLowerCase()) {
      case 'active':
      case 'aktiv':
        return Colors.green.shade700;
      case 'paused':
      case 'pausiert':
        return Colors.orange.shade800;
      case 'archived':
      case 'archiv':
      case 'archived_actions':
        return Colors.grey.shade800;
      case 'draft':
        return Colors.blue.shade700;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _textColor(context),
        ),
      ),
    );
  }
}