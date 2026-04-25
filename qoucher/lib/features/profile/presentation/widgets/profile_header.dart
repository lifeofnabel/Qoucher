import 'package:flutter/material.dart';

class MerchantProfileHeader extends StatelessWidget {
  const MerchantProfileHeader({
    super.key,
    required this.businessName,
    this.description,
    this.address,
    this.categories = const [],
    this.logoUrl,
  });

  final String businessName;
  final String? description;
  final String? address;
  final List<String> categories;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final firstLetter = businessName.isNotEmpty
        ? businessName.substring(0, 1).toUpperCase()
        : 'S';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              businessName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'powered by Qoucher',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                description!,
                textAlign: TextAlign.center,
              ),
            ],
            if (address != null && address!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                address!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: categories
                    .map(
                      (category) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}