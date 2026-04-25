import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_shop_controller.dart';

class MerchantShopPage extends StatefulWidget {
  const MerchantShopPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantShopPage> createState() => _MerchantShopPageState();
}

class _MerchantShopPageState extends State<MerchantShopPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantShopController>().loadShop(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantShopController>(
      builder: (context, controller, _) {
        final profile = controller.profile ?? {};

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mein Shop'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${profile['businessName'] ?? 'Mein Shop'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text('${profile['description'] ?? ''}'),
                    const SizedBox(height: 20),
                    Text(
                      'Aktive Aktionen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (controller.activeActions.isEmpty)
                      const Text('Keine aktiven Aktionen.'),
                    ...controller.activeActions.map(
                      (action) => Card(
                        child: ListTile(
                          title: Text(action.title),
                          subtitle: Text(action.description),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Artikel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (controller.items.isEmpty)
                      const Text('Keine Artikel vorhanden.'),
                    ...controller.items.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.description}\n${item.originalPrice.toStringAsFixed(2)} €',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Rewards',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (controller.rewards.isEmpty)
                      const Text('Keine Rewards vorhanden.'),
                    ...controller.rewards.map(
                      (reward) => Card(
                        child: ListTile(
                          title: Text(reward.title),
                          subtitle: Text(
                            '${reward.description}\nTyp: ${reward.rewardType}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}