import 'package:flutter/material.dart';

class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    required this.liveCode,
    this.qrText,
    this.title = 'Mein QR',
    this.subtitle = 'Zeige diesen Code dem Laden',
  });

  final String liveCode;
  final String? qrText;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final displayQrText = (qrText == null || qrText!.trim().isEmpty)
        ? liveCode
        : qrText!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
              ),
              alignment: Alignment.center,
              child: Text(
                displayQrText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Temporärer Live-Code',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              liveCode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}