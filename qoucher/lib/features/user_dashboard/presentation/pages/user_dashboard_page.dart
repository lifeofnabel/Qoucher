import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/user_dashboard/presentation/controllers/user_dashboard_controller.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/loyalty_wallet_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_activity_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_qr_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_rewards_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserDashboardController>().loadDashboard(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('User Dashboard'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => controller.loadDashboard(widget.userId),
            child: ListView(
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
                          radius: 34,
                          child: Text(
                            controller.firstName.isNotEmpty
                                ? controller.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.firstName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gesamtpunkte: ${controller.totalPoints}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.15,
                  children: [
                    _tile(
                      context,
                      title: 'Mein QR',
                      icon: Icons.qr_code,
                      onTap: () => _open(
                        context,
                        MyQrPage(userId: widget.userId),
                      ),
                    ),
                    _tile(
                      context,
                      title: 'Meine Rewards',
                      icon: Icons.card_giftcard,
                      onTap: () => _open(
                        context,
                        MyRewardsPage(userId: widget.userId),
                      ),
                    ),
                    _tile(
                      context,
                      title: 'Loyalty Wallet',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => _open(
                        context,
                        LoyaltyWalletPage(userId: widget.userId),
                      ),
                    ),
                    _tile(
                      context,
                      title: 'Meine Aktivität',
                      icon: Icons.history,
                      onTap: () => _open(
                        context,
                        MyActivityPage(userId: widget.userId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}