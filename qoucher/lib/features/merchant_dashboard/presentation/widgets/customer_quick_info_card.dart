import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/scanned_customer_model.dart';

class CustomerQuickInfoCard extends StatelessWidget {
  const CustomerQuickInfoCard({
    super.key,
    required this.customer,
    this.onMoreTap,
  });

  final ScannedCustomerModel customer;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    customer.firstName.isNotEmpty
                        ? customer.firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    customer.firstName.isNotEmpty
                        ? customer.firstName
                        : 'Unbekannter Kunde',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onMoreTap != null)
                  TextButton(
                    onPressed: onMoreTap,
                    child: const Text('Mehr'),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow('Username', customer.username),
            _infoRow('E-Mail', customer.email),
            _infoRow('Punkte', '${customer.points}'),
            _infoRow('Coupons', '${customer.activeCoupons.length}'),
            _infoRow('Stempelkarten', '${customer.stampCards.length}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }
}