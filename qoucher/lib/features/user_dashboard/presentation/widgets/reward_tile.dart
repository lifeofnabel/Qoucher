import 'package:flutter/material.dart';

class RewardTile extends StatelessWidget {
  const RewardTile({
    super.key,
    required this.title,
    this.description,
    this.shopName,
    this.pointsText,
    this.onTap,
    this.onRedeem,
    this.showRedeemButton = false,
  });

  final String title;
  final String? description;
  final String? shopName;
  final String? pointsText;
  final VoidCallback? onTap;
  final VoidCallback? onRedeem;
  final bool showRedeemButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(description!),
              ],
              const SizedBox(height: 10),
              if (shopName != null && shopName!.isNotEmpty)
                Text(
                  'Shop: $shopName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (pointsText != null && pointsText!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  pointsText!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (showRedeemButton && onRedeem != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onRedeem,
                    child: const Text('Einlösen'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}