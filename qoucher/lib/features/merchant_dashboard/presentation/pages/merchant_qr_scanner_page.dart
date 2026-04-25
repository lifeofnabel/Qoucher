import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_qr_controller.dart';

class MerchantQrScannerPage extends StatefulWidget {
  const MerchantQrScannerPage({
    super.key,
    required this.merchantId,
    required this.pointsPerEuro,
  });

  final String merchantId;
  final double pointsPerEuro;

  @override
  State<MerchantQrScannerPage> createState() => _MerchantQrScannerPageState();
}

class _MerchantQrScannerPageState extends State<MerchantQrScannerPage> {
  final _liveCodeController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  Future<void> _scanCustomer() async {
    final controller = context.read<MerchantQrController>();
    final success = await controller.scanCustomer(_liveCodeController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Kunde gefunden.' : (controller.errorMessage ?? 'Fehler'),
        ),
      ),
    );
  }

  Future<void> _assignPoints() async {
    final controller = context.read<MerchantQrController>();
    final customer = controller.scannedCustomer;
    if (customer == null) return;

    final success = await controller.assignPoints(
      merchantId: widget.merchantId,
      customerId: customer.uid,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      pointsPerEuro: widget.pointsPerEuro,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Punkte gutgeschrieben.' : (controller.errorMessage ?? 'Fehler'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantQrController>(
      builder: (context, controller, _) {
        final customer = controller.scannedCustomer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('QR Scanner'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Kunden-Code eingeben',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _liveCodeController,
                decoration: const InputDecoration(
                  labelText: 'Live Code / QR Ersatz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _scanCustomer,
                  child: controller.isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Kunden laden'),
                ),
              ),
              const SizedBox(height: 24),
              if (customer != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.firstName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text('Username: ${customer.username}'),
                        Text('E-Mail: ${customer.email}'),
                        Text('Punkte: ${customer.points}'),
                        Text('Coupons aktiv: ${customer.activeCoupons.length}'),
                        Text('Stempelkarten: ${customer.stampCards.length}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Betrag',
                    border: OutlineInputBorder(),
                    suffixText: '€',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Kommentar optional',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting ? null : _assignPoints,
                    child: controller.isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Punkte vergeben'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _liveCodeController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}