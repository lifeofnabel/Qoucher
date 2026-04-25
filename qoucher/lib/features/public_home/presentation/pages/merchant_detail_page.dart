import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/public_home/presentation/controllers/public_home_controller.dart';

class MerchantDetailsPage extends StatefulWidget {
  const MerchantDetailsPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantDetailsPage> createState() => _MerchantDetailsPageState();
}

class _MerchantDetailsPageState extends State<MerchantDetailsPage> {
  Map<String, dynamic>? merchant;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMerchant);
  }

  Future<void> _loadMerchant() async {
    final controller = context.read<PublicHomeController>();

    try {
      final result = await controller.getMerchantDetails(widget.merchantId);

      if (!mounted) return;

      setState(() {
        merchant = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = merchant ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      ((data['businessName'] ?? 'S').toString())
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${data['businessName'] ?? 'Shop'}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data['description'] ?? ''}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${data['address'] ?? ''}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: const Text('Kategorie'),
              subtitle: Text('${data['categories'] ?? '-'}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Telefon'),
              subtitle: Text('${data['phone'] ?? '-'}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('E-Mail'),
              subtitle: Text('${data['email'] ?? '-'}'),
            ),
          ),
        ],
      ),
    );
  }
}