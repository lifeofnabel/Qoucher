import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_qr_controller.dart';

class MerchantScannedHistoryPage extends StatefulWidget {
  const MerchantScannedHistoryPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantScannedHistoryPage> createState() =>
      _MerchantScannedHistoryPageState();
}

class _MerchantScannedHistoryPageState
    extends State<MerchantScannedHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantQrController>().loadScannedHistory(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantQrController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scanned History'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.scannedHistory.isEmpty
              ? const Center(child: Text('Noch keine Scans vorhanden.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.scannedHistory.length,
            itemBuilder: (context, index) {
              final scan = controller.scannedHistory[index];

              return Card(
                child: ListTile(
                  title: Text(scan.type),
                  subtitle: Text(
                    'Customer: ${scan.customerId}\n'
                        'Punkte: ${scan.pointsAdded ?? '-'} | Betrag: ${scan.amount ?? '-'}\n'
                        'Kommentar: ${scan.comment ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    scan.createdAt != null
                        ? '${scan.createdAt!.day}.${scan.createdAt!.month}'
                        : '-',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}