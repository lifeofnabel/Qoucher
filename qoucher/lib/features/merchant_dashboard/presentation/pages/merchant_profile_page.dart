import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_account_controller.dart';

class MerchantProfilePage extends StatefulWidget {
  const MerchantProfilePage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantProfilePage> createState() => _MerchantProfilePageState();
}

class _MerchantProfilePageState extends State<MerchantProfilePage> {
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
            title: const Text('Mein Profil'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 42,
                child: Text(
                  ((profile['businessName'] ?? 'S').toString()).isNotEmpty
                      ? (profile['businessName'] ?? 'S')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase()
                      : 'S',
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${profile['businessName'] ?? 'Mein Shop'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'powered by Qoucher',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              _profileCard('Business Name', '${profile['businessName'] ?? '-'}'),
              _profileCard('Kontaktname', '${profile['contactName'] ?? '-'}'),
              _profileCard('E-Mail', '${profile['email'] ?? '-'}'),
              _profileCard('Telefon', '${profile['phone'] ?? '-'}'),
              _profileCard('Adresse', '${profile['address'] ?? '-'}'),
              _profileCard('Beschreibung', '${profile['description'] ?? '-'}'),
              _profileCard('Logo URL', '${profile['logoUrl'] ?? '-'}'),
              _profileCard('Kategorien', '${profile['categories'] ?? '-'}'),
            ],
          ),
        );
      },
    );
  }

  Widget _profileCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}