import 'package:flutter/material.dart';

class RewardRedemptionTile extends StatelessWidget {
  const RewardRedemptionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.pointsText,
    this.onRedeem,
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final String? pointsText;
  final VoidCallback? onRedeem;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtitle!),
            ],
            if (pointsText != null && pointsText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                pointsText!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        trailing: FilledButton(
          onPressed: isLoading ? null : onRedeem,
          child: isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Einlösen'),
        ),
      ),
    );
  }
}