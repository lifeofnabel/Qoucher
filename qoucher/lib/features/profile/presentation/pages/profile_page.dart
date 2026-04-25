import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_profile_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/widgets/merchant_dashboard_header.dart';

import '../widgets/profile_header.dart';

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
      context.read<MerchantProfileController>().loadProfile(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mein Profil'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(controller.errorMessage!),
            ),
          )
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MerchantProfileHeader(
                businessName: controller.businessName,
                description: controller.description,
                address: controller.address,
                categories: controller.categories,
                logoUrl: controller.logoUrl,
              ),
              const SizedBox(height: 20),
              _infoCard(
                context,
                title: 'Kontaktname',
                value: controller.contactName,
              ),
              _infoCard(
                context,
                title: 'E-Mail',
                value: controller.email,
              ),
              _infoCard(
                context,
                title: 'Telefon',
                value: controller.phone,
              ),
              _infoCard(
                context,
                title: 'Adresse',
                value: controller.address,
              ),
              _infoCard(
                context,
                title: 'Beschreibung',
                value: controller.description,
              ),
              _infoCard(
                context,
                title: 'Logo URL',
                value: controller.logoUrl,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(
      BuildContext context, {
        required String title,
        required String value,
      }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }
}