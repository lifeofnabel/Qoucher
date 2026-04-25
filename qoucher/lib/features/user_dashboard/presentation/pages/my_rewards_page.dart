import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/user_dashboard/presentation/controllers/user_dashboard_controller.dart';

class MyRewardsPage extends StatefulWidget {
  const MyRewardsPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MyRewardsPage> createState() => _MyRewardsPageState();
}

class _MyRewardsPageState extends State<MyRewardsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserDashboardController>().loadRewards(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine Rewards'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.rewards.isEmpty
              ? const Center(child: Text('Noch keine Rewards verfügbar.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.rewards.length,
            itemBuilder: (context, index) {
              final reward = controller.rewards[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    '${reward['title'] ?? 'Reward'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${reward['description'] ?? ''}\n'
                        'Shop: ${reward['shopName'] ?? '-'}',
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