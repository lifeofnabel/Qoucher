import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/user_dashboard/presentation/controllers/user_dashboard_controller.dart';

class LoyaltyWalletPage extends StatefulWidget {
  const LoyaltyWalletPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<LoyaltyWalletPage> createState() => _LoyaltyWalletPageState();
}

class _LoyaltyWalletPageState extends State<LoyaltyWalletPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserDashboardController>().loadLoyaltyWallet(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Loyalty Wallet'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.loyaltyWallet.isEmpty
              ? const Center(child: Text('Noch keine Loyalty-Einträge.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.loyaltyWallet.length,
            itemBuilder: (context, index) {
              final item = controller.loyaltyWallet[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    '${item['shopName'] ?? 'Shop'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Punkte: ${item['points'] ?? 0}\n'
                        'Stempel: ${item['stamps'] ?? 0}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}