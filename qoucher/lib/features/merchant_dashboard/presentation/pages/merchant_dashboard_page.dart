import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:qoucher/features/merchant_dashboard/data/repositories/merchant_dashboard_repository.dart';

import 'package:qoucher/features/merchant_dashboard/domain/usecases/assign_points_from_amount.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/create_merchant_action.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_archived_actions.dart';
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
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_shop_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_stamp_controller.dart';

import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_archived_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_create_action_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_items_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_points_system_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_profile_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_qr_scanner_page.dart';
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
        const pointsPerEuro = 1.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                onPressed: () => _openProfilePage(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
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

                _wideSystemTile(
                  context,
                  title: 'Punktesystem',
                  subtitle: 'Punkte pro € festlegen und Kunden automatisch belohnen',
                  icon: Icons.stars_outlined,
                  onTap: () => _openPointsPage(context),
                ),

                const SizedBox(height: 12),

                _wideSystemTile(
                  context,
                  title: 'Stempelkarte',
                  subtitle: 'Digitale Karte für Besuche, Käufe oder Aktionen',
                  icon: Icons.style_outlined,
                  onTap: () => _openStampPage(context),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        title: 'Aktive Aktionen',
                        value: '${controller.activeActionsCount}',
                        icon: Icons.local_fire_department_outlined,
                        onTap: () => _showActiveActionsPopup(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        context,
                        title: 'Gescannt heute',
                        value: '${controller.scannedTodayCount}',
                        icon: Icons.qr_code_2_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _sectionTitle(context, 'Aktionen'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Rabatt-Aktion',
                        icon: Icons.percent,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _gridTile(
                        context,
                        title: '2 für 1 / 2+1',
                        icon: Icons.local_offer_outlined,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Gratis Coupon',
                        icon: Icons.card_giftcard_outlined,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Happy Hour',
                        icon: Icons.access_time_filled_outlined,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Individueller Beitrag',
                        icon: Icons.edit_note_outlined,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'MHD-Ware',
                        icon: Icons.schedule_outlined,
                        onTap: () => _openCreateActionPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _sectionTitle(context, 'Verwaltung'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Meine Artikel',
                        icon: Icons.inventory_2_outlined,
                        onTap: () => _openItemsPage(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Öffentlicher Shop',
                        icon: Icons.storefront_outlined,
                        onTap: () => _openShopPage(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Scans heute',
                        icon: Icons.history,
                        onTap: () => _openScannedHistoryPage(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _gridTile(
                        context,
                        title: 'Ausloggen',
                        icon: Icons.logout,
                        onTap: () => _logout(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.16),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 38,
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
                    'Kundenkarte scannen, Punkte vergeben oder Coupon prüfen.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
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
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _wideSystemTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.13),
              ),
              child: Icon(icon, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 118,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActiveActionsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aktive Aktionen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),

              _popupActionRow(
                context,
                title: 'Babel Deal',
                subtitle: '10% Rabatt auf ausgewählte Artikel',
                icon: Icons.local_fire_department_outlined,
              ),
              _popupActionRow(
                context,
                title: 'Happy Hour',
                subtitle: 'Heute aktiv',
                icon: Icons.access_time_outlined,
              ),
              _popupActionRow(
                context,
                title: 'Stempelkarte',
                subtitle: 'Jeder 10. Besuch bekommt Bonus',
                icon: Icons.style_outlined,
              ),

              const SizedBox(height: 8),

              Text(
                'Nur Übersicht. Bearbeitung kommt später.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _popupActionRow(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
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