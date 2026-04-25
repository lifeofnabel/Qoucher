import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_account_controller.dart';

class MerchantAccountDataPage extends StatefulWidget {
  const MerchantAccountDataPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantAccountDataPage> createState() =>
      _MerchantAccountDataPageState();
}

class _MerchantAccountDataPageState extends State<MerchantAccountDataPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantAccountController>().loadProfile(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantAccountController>(
      builder: (context, controller, _) {
        final profile = controller.profile ?? {};

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Data'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard('Business Name', '${profile['businessName'] ?? '-'}'),
              _infoCard('Kontaktname', '${profile['contactName'] ?? '-'}'),
              _infoCard('E-Mail', '${profile['email'] ?? '-'}'),
              _infoCard('Telefon', '${profile['phone'] ?? '-'}'),
              _infoCard('Adresse', '${profile['address'] ?? '-'}'),
              _infoCard('Beschreibung', '${profile['description'] ?? '-'}'),
              _infoCard('Logo', '${profile['logoUrl'] ?? '-'}'),
              _infoCard('Kategorien', '${profile['categories'] ?? '-'}'),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}