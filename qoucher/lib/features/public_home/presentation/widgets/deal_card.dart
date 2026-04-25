import 'package:flutter/material.dart';

class PublicDealCard extends StatelessWidget {
  const PublicDealCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.shopName,
    this.area,
    this.type,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final String? shopName;
  final String? area;
  final String? type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (type != null && type!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    type!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (type != null && type!.isNotEmpty) const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(description!),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (shopName != null && shopName!.isNotEmpty)
                    Expanded(
                      child: Text(
                        shopName!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (area != null && area!.isNotEmpty)
                    Text(
                      area!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}