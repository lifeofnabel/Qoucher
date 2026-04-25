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
        final businessName =
        (profile['businessName'] ?? profile['firstName'] ?? 'Mein Shop')
            .toString();
        final description = (profile['description'] ?? '').toString();
        final address = (profile['address'] ?? '').toString();
        final categories = profile['categories'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mein Shop'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => controller.loadShop(widget.merchantId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(
                  context,
                  businessName: businessName,
                  description: description,
                  address: address,
                  categories: categories,
                ),
                const SizedBox(height: 20),

                _sectionTitle(context, 'Aktive Aktionen'),
                const SizedBox(height: 10),
                if (controller.activeActions.isEmpty)
                  _emptyCard('Keine aktiven Aktionen vorhanden.')
                else
                  ...controller.activeActions.map(
                        (action) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (action.subtitle.isNotEmpty)
                              Text(
                                action.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(action.description),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _chip(action.type),
                                _chip(action.status),
                                _chip(
                                  action.endsAt == null
                                      ? 'unbegrenzt'
                                      : 'bis ${action.endsAt!.day}.${action.endsAt!.month}.${action.endsAt!.year}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                _sectionTitle(context, 'Artikel'),
                const SizedBox(height: 10),
                if (controller.items.isEmpty)
                  _emptyCard('Keine Artikel vorhanden.')
                else
                  ...controller.items.map(
                        (item) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${item.description}\n'
                                '${item.originalPrice.toStringAsFixed(2)} € · ${item.category}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          item.isActive
                              ? Icons.check_circle
                              : Icons.pause_circle,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                _sectionTitle(context, 'Rewards'),
                const SizedBox(height: 10),
                if (controller.rewards.isEmpty)
                  _emptyCard('Keine Rewards vorhanden.')
                else
                  ...controller.rewards.map(
                        (reward) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        title: Text(
                          reward.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${reward.description}\n'
                                'Typ: ${reward.rewardType}'
                                '${reward.requiredPoints != null ? '\nPunkte: ${reward.requiredPoints}' : ''}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          reward.isActive
                              ? Icons.card_giftcard
                              : Icons.pause_circle,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, {
        required String businessName,
        required String description,
        required String address,
        required dynamic categories,
      }) {
    return Card(
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
                businessName.isNotEmpty
                    ? businessName.substring(0, 1).toUpperCase()
                    : 'S',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              businessName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'powered by Qoucher',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                description,
                textAlign: TextAlign.center,
              ),
            ],
            if (address.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                address,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (categories != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _buildCategoryChips(categories),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryChips(dynamic categories) {
    if (categories is List) {
      return categories
          .map(
            (category) => _chip(category.toString()),
      )
          .toList();
    }

    return [_chip(categories.toString())];
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}