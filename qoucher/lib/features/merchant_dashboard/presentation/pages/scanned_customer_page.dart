import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_qr_controller.dart';

class ScannedCustomerPage extends StatefulWidget {
  const ScannedCustomerPage({
    super.key,
    required this.merchantId,
    required this.customerCode,
    required this.pointsPerEuro,
  });

  final String merchantId;
  final String customerCode;
  final double pointsPerEuro;

  @override
  State<ScannedCustomerPage> createState() => _ScannedCustomerPageState();
}

class _ScannedCustomerPageState extends State<ScannedCustomerPage> {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantQrController>().scanCustomer(widget.customerCode);
    });
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
        content: Text(success ? 'Punkte vergeben.' : (controller.errorMessage ?? 'Fehler')),
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
            title: const Text('Kunde'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : customer == null
              ? const Center(child: Text('Kein Kunde gefunden.'))
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.firstName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Username: ${customer.username}'),
                      Text('E-Mail: ${customer.email}'),
                      Text('Punkte: ${customer.points}'),
                      Text('Aktive Coupons: ${customer.activeCoupons.length}'),
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}