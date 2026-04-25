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
  final TextEditingController _liveCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  Future<void> _scanCustomer() async {
    final controller = context.read<MerchantQrController>();

    final success = await controller.scanCustomer(
      _liveCodeController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Kunde gefunden.'
              : (controller.errorMessage ?? 'Fehler beim Laden des Kunden.'),
        ),
      ),
    );
  }

  Future<void> _assignPoints() async {
    final controller = context.read<MerchantQrController>();
    final customer = controller.scannedCustomer;

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kein Kunde geladen.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gültigen Betrag eingeben.'),
        ),
      );
      return;
    }

    final success = await controller.assignPoints(
      merchantId: widget.merchantId,
      customerId: customer.uid,
      amount: amount,
      pointsPerEuro: widget.pointsPerEuro,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Punkte erfolgreich vergeben.'
              : (controller.errorMessage ?? 'Fehler beim Vergeben der Punkte.'),
        ),
      ),
    );

    if (success) {
      _amountController.clear();
      _commentController.clear();
    }
  }

  Future<void> _redeemReward(String rewardId) async {
    final controller = context.read<MerchantQrController>();
    final customer = controller.scannedCustomer;

    if (customer == null) return;

    final success = await controller.redeemCustomerReward(
      merchantId: widget.merchantId,
      customerId: customer.uid,
      rewardId: rewardId,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reward eingelöst.'
              : (controller.errorMessage ?? 'Fehler beim Einlösen.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantQrController>(
      builder: (context, controller, _) {
        final customer = controller.scannedCustomer;
        final calculatedPoints = (() {
          final amount = double.tryParse(_amountController.text.trim()) ?? 0;
          return (amount * widget.pointsPerEuro).floor();
        })();

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
              const SizedBox(height: 8),
              Text(
                'Hier kann der temporäre Live-Code oder QR-Ersatz eingegeben werden.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _liveCodeController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Live Code / 3x3 Zahlencode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: const Icon(Icons.qr_code_2_outlined),
                ),
                onSubmitted: (_) => _scanCustomer(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : _scanCustomer,
                  icon: controller.isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.search),
                  label: const Text('Kunde laden'),
                ),
              ),
              const SizedBox(height: 20),
              if (customer != null) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.firstName.isNotEmpty
                              ? customer.firstName
                              : 'Unbekannter Kunde',
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow('Username', customer.username),
                        _infoRow('E-Mail', customer.email),
                        _infoRow('Punkte', '${customer.points}'),
                        _infoRow(
                          'Aktive Coupons',
                          '${customer.activeCoupons.length}',
                        ),
                        _infoRow(
                          'Stempelkarten',
                          '${customer.stampCards.length}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Punkte vergeben',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Betrag',
                    suffixText: '€',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Automatisch berechnete Punkte',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$calculatedPoints',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Kommentar optional',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting ? null : _assignPoints,
                    icon: controller.isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.add_circle_outline),
                    label: const Text('Punkte vergeben'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aktive Coupons / Rewards',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (customer.activeCoupons.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Keine aktiven Coupons vorhanden.'),
                    ),
                  )
                else
                  ...customer.activeCoupons.map((coupon) {
                    final couponMap = coupon is Map<String, dynamic>
                        ? coupon
                        : <String, dynamic>{};
                    final rewardId =
                    (couponMap['rewardId'] ?? couponMap['id'] ?? '')
                        .toString();
                    final title =
                    (couponMap['title'] ?? 'Reward').toString();
                    final subtitle =
                    (couponMap['subtitle'] ?? '').toString();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(title),
                        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                        trailing: FilledButton(
                          onPressed: rewardId.isEmpty
                              ? null
                              : () => _redeemReward(rewardId),
                          child: const Text('Einlösen'),
                        ),
                      ),
                    );
                  }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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

  @override
  void dispose() {
    _liveCodeController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}