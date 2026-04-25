import 'package:flutter/material.dart';

class PointsInputCard extends StatelessWidget {
  const PointsInputCard({
    super.key,
    required this.amountController,
    required this.commentController,
    required this.pointsPerEuro,
    required this.onAssign,
    this.isLoading = false,
  });

  final TextEditingController amountController;
  final TextEditingController commentController;
  final double pointsPerEuro;
  final VoidCallback onAssign;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final calculatedPoints = (amount * pointsPerEuro).floor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Punkte vergeben',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Betrag',
                suffixText: '€',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Automatisch berechnete Punkte',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$calculatedPoints',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Kommentar optional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onAssign,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.add_circle_outline),
                label: const Text('Punkte vergeben'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}