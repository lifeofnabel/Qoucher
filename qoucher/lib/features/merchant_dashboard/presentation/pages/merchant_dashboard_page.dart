import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qoucher/features/merchant_dashboard/data/repositories/merchant_dashboard_repository.dart';

import 'package:qoucher/features/merchant_dashboard/domain/usecases/assign_points_from_amount.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/create_merchant_action.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_archived_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_merchant_dashboard_data.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_scanned_history.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/pause_merchant_action.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/redeem_reward.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/scan_customer_code.dart';

import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_actions_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_create_action_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_dashboard_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_items_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_points_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_profile_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_qr_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_rewards_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_shop_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_stamp_controller.dart';

import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_archived_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_create_action_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_items_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_points_system_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_profile_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_qr_scanner_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_rewards_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_scanned_history_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_shop_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_stamp_system_page.dart';

class MerchantDashboardPage extends StatefulWidget {
  const MerchantDashboardPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  late final MerchantDashboardRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = MerchantDashboardRepository();

    Future.microtask(() {
      context.read<MerchantDashboardController>().loadDashboard(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantDashboardController>(
      builder: (context, controller, _) {
        final shopName = controller.businessName;
        final pointsPerEuro = 1.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Merchant Dashboard'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => controller.loadDashboard(widget.merchantId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(
                  context,
                  businessName: shopName,
                ),
                const SizedBox(height: 18),

                _buildPrimaryScannerCard(
                  context,
                  onTap: () => _openQrScannerPage(
                    context,
                    pointsPerEuro: pointsPerEuro,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        'Aktive Aktionen',
                        '${controller.activeActionsCount}',
                        Icons.campaign_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        context,
                        'Archiv',
                        '${controller.archivedActionsCount}',
                        Icons.archive_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _statCard(
                  context,
                  'Gescannt heute',
                  '${controller.scannedTodayCount}',
                  Icons.history,
                ),
                const SizedBox(height: 20),

                Text(
                  'Verwalten',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.10,
                  children: [
                    _dashboardTile(
                      context,
                      title: 'Neue Aktion',
                      icon: Icons.add_circle_outline,
                      subtitle: 'Aktion starten',
                      onTap: () => _openCreateActionPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Aktive Aktionen',
                      icon: Icons.flash_on_outlined,
                      subtitle: 'Laufende Aktionen',
                      onTap: () => _openActionsPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Archiv',
                      icon: Icons.archive_outlined,
                      subtitle: 'Deaktivierte Aktionen',
                      onTap: () => _openArchivedActionsPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Gescannt heute',
                      icon: Icons.qr_code_2_outlined,
                      subtitle: 'Scan-Verlauf',
                      onTap: () => _openScannedHistoryPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Meine Artikel',
                      icon: Icons.inventory_2_outlined,
                      subtitle: 'Produkte verwalten',
                      onTap: () => _openItemsPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Rewards',
                      icon: Icons.card_giftcard,
                      subtitle: 'Belohnungen',
                      onTap: () => _openRewardsPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Punktesystem',
                      icon: Icons.stars_outlined,
                      subtitle: 'Punkte pro €',
                      onTap: () => _openPointsPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Stempelsystem',
                      icon: Icons.style_outlined,
                      subtitle: 'Digitale Stempelkarten',
                      onTap: () => _openStampPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Mein Shop',
                      icon: Icons.storefront_outlined,
                      subtitle: 'Öffentliche Ansicht',
                      onTap: () => _openShopPage(context),
                    ),
                    _dashboardTile(
                      context,
                      title: 'Profil',
                      icon: Icons.person_outline,
                      subtitle: 'Shopdaten',
                      onTap: () => _openProfilePage(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
      }) {
    final firstLetter =
    businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'S';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'powered by Qoucher',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context
                    .read<MerchantDashboardController>()
                    .loadDashboard(widget.merchantId);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryScannerCard(
      BuildContext context, {
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.16),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Scanner',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kunde laden, Punkte vergeben, Rewards einlösen.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQrScannerPage(
      BuildContext context, {
        required double pointsPerEuro,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantQrController(
            scanCustomerByLiveCode: ScanCustomerByLiveCode(_repository),
            assignPointsFromAmount: AssignPointsFromAmount(_repository),
            redeemReward: RedeemReward(_repository),
            getScannedHistory: GetScannedHistory(_repository),
          ),
          child: MerchantQrScannerPage(
            merchantId: widget.merchantId,
            pointsPerEuro: pointsPerEuro,
          ),
        ),
      ),
    );
  }

  void _openActionsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantActionsController(
            getActiveActions: GetActiveActions(_repository),
            getArchivedActions: GetArchivedActions(_repository),
            pauseMerchantAction: PauseMerchantAction(_repository),
          ),
          child: MerchantActionsPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openArchivedActionsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantActionsController(
            getActiveActions: GetActiveActions(_repository),
            getArchivedActions: GetArchivedActions(_repository),
            pauseMerchantAction: PauseMerchantAction(_repository),
          ),
          child: MerchantArchivedActionsPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openCreateActionPage(
      BuildContext context, {
        required String shopName,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantCreateActionController(
            createMerchantAction: CreateMerchantAction(_repository),
          ),
          child: MerchantCreateActionPage(
            merchantId: widget.merchantId,
            shopName: shopName,
          ),
        ),
      ),
    );
  }

  void _openScannedHistoryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantQrController(
            scanCustomerByLiveCode: ScanCustomerByLiveCode(_repository),
            assignPointsFromAmount: AssignPointsFromAmount(_repository),
            redeemReward: RedeemReward(_repository),
            getScannedHistory: GetScannedHistory(_repository),
          ),
          child: MerchantScannedHistoryPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openItemsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantItemsController(
            repository: _repository,
          ),
          child: MerchantItemsPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openRewardsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantRewardsController(
            repository: _repository,
          ),
          child: MerchantRewardsPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openPointsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantPointsController(
            repository: _repository,
          ),
          child: MerchantPointsSystemPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openStampPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantStampController(
            repository: _repository,
          ),
          child: MerchantStampSystemPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openProfilePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantProfileController(
            repository: _repository,
          ),
          child: MerchantProfilePage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }

  void _openShopPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MerchantShopController(
            repository: _repository,
          ),
          child: MerchantShopPage(
            merchantId: widget.merchantId,
          ),
        ),
      ),
    );
  }
}