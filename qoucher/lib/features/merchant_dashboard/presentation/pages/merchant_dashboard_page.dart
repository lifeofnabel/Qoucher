import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:qoucher/core/constants/app_colors.dart';

import 'package:qoucher/features/merchant_dashboard/data/repositories/merchant_dashboard_repository.dart';

import 'package:qoucher/features/merchant_dashboard/domain/usecases/assign_points_from_amount.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_archived_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_scanned_history.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/pause_merchant_action.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/redeem_reward.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/scan_customer_code.dart';

import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_actions_controller.dart';
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
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_bundle_deals_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_happy_hour_deals_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_custom_post_deals_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_free_item_deals_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_rescue_deals_page.dart';

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
        final shopName = controller.businessName.trim().isEmpty
            ? 'Dein Shop'
            : controller.businessName.trim();

        const pointsPerEuro = 1.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 18,
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            actions: [
              _topIconButton(
                icon: Icons.settings_outlined,
                onTap: () => _openProfilePage(context),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: controller.isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.black,
            ),
          )
              : RefreshIndicator(
            color: AppColors.black,
            backgroundColor: AppColors.surface,
            onRefresh: () => controller.loadDashboard(widget.merchantId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _buildHeaderCard(
                  businessName: shopName,
                  onRefresh: () {
                    context
                        .read<MerchantDashboardController>()
                        .loadDashboard(widget.merchantId);
                  },
                ),

                const SizedBox(height: 16),

                _buildPrimaryScannerCard(
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
                        title: 'Aktive Aktionen',
                        value: '${controller.activeActionsCount}',
                        tone: _DashboardTone.neutral,
                        onTap: () => _showActiveActionsPopup(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: 'Scans heute',
                        value: '${controller.scannedTodayCount}',
                        tone: _DashboardTone.neutral,
                        onTap: () => _openScannedHistoryPage(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _sectionTitle(
                  title: 'Meine Systeme',
                  subtitle: 'Punkte und Stempel sauber verwalten.',
                ),

                const SizedBox(height: 12),

                _wideTile(
                  title: 'Punktesystem',
                  subtitle: 'Punkte pro € festlegen und Monats-Rewards steuern.',
                  icon: Icons.stars_rounded,
                  badge: 'Reward',
                  tone: _DashboardTone.system,
                  onTap: () => _openPointsPage(context),
                ),

                const SizedBox(height: 12),

                _wideTile(
                  title: 'Stempelkarten',
                  subtitle: 'Mehrere Karten für Besuche, Käufe oder Aktionen.',
                  icon: Icons.style_rounded,
                  badge: 'Loyalty',
                  tone: _DashboardTone.system,
                  onTap: () => _openStampPage(context),
                ),


                const SizedBox(height: 12),

                _dashboardGrid(
                  children: [
                    _smallTile(
                      title: 'Gratis',
                      subtitle: 'Kaufe X, erhalte Y',
                      icon: Icons.card_giftcard_rounded,
                      tone: _DashboardTone.action,
                      onTap: () => _openFreeItemDealsPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                      _smallTile(
                        title: '2 für 1',
                        subtitle: 'Bundle Deal',
                        icon: Icons.filter_2_rounded,
                        tone: _DashboardTone.action,
                        onTap: () => _openBundleDealsPage(
                          context,
                          shopName: shopName,
                        ),
                      ),
                    _smallTile(
                      title: 'Gratis',
                      subtitle: 'Coupon',
                      icon: Icons.card_giftcard_rounded,
                      tone: _DashboardTone.action,
                      onTap: () => _openDiscountActionsPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                    _smallTile(
                      title: 'Happy Hour',
                      subtitle: 'Zeitfenster',
                      icon: Icons.access_time_filled_rounded,
                      tone: _DashboardTone.action,
                      onTap: () => _openHappyHourDealsPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                    _smallTile(
                      title: 'Beitrag',
                      subtitle: 'Frei bauen',
                      icon: Icons.edit_note_rounded,
                      tone: _DashboardTone.action,
                      onTap: () => _openCustomPostDealsPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                    _smallTile(
                      title: 'Rette mich',
                      subtitle: 'MHD & Tagesware',
                      icon: Icons.schedule_rounded,
                      tone: _DashboardTone.action,
                      onTap: () => _openRescueDealsPage(
                        context,
                        shopName: shopName,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _sectionTitle(
                  title: 'Shop-Verwaltung',
                  subtitle: 'Artikel, Shopseite und Verlauf.',
                ),

                const SizedBox(height: 12),

                _dashboardGrid(
                  children: [
                    _smallTile(
                      title: 'Artikel',
                      subtitle: 'Sortiment',
                      icon: Icons.inventory_2_rounded,
                      tone: _DashboardTone.neutral,
                      onTap: () => _openItemsPage(context),
                    ),
                    _smallTile(
                      title: 'Shop',
                      subtitle: 'Öffentlich',
                      icon: Icons.storefront_rounded,
                      tone: _DashboardTone.neutral,
                      onTap: () => _openShopPage(context),
                    ),
                    _smallTile(
                      title: 'Verlauf',
                      subtitle: 'Scans',
                      icon: Icons.history_rounded,
                      tone: _DashboardTone.neutral,
                      onTap: () => _openScannedHistoryPage(context),
                    ),
                    _smallTile(
                      title: 'Archiv',
                      subtitle: 'Pausiert',
                      icon: Icons.archive_rounded,
                      tone: _DashboardTone.neutral,
                      onTap: () => _openArchivedActionsPage(context),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _logoutTile(
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1.1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.black,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required String businessName,
    required VoidCallback onRefresh,
  }) {
    final firstLetter =
    businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'S';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5D2AF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFC8A96A),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC8A96A),
                width: 2,
              ),
            ),
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            businessName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'powered by Qoucher',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFC8A96A),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: AppColors.black,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Aktualisieren',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryScannerCard({
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD9BE86),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF8F6B24),
            width: 1.6,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF8F6B24),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 40,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 17),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Scanner',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kundenkarte scannen, Punkte geben oder Coupon prüfen.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required _DashboardTone tone,
    VoidCallback? onTap,
  }) {
    final colors = _toneColors(tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.border,
            width: 1.15,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _wideTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required _DashboardTone tone,
    required VoidCallback onTap,
  }) {
    final colors = _toneColors(tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: colors.border,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _iconBox(
              icon: icon,
              colors: colors,
              size: 62,
              iconSize: 31,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.bg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: colors.fg,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD6D9),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFE8757C),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFB5121B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 31,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.black,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardGrid({
    required List<Widget> children,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.05,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget _smallTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required _DashboardTone tone,
    required VoidCallback onTap,
  }) {
    final colors = _toneColors(tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.border,
            width: 1.15,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(
              icon: icon,
              colors: colors,
              size: 47,
              iconSize: 25,
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox({
    required IconData icon,
    required _ToneColors colors,
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(size * 0.34),
        border: Border.all(
          color: colors.border,
          width: 0.9,
        ),
      ),
      child: Icon(
        icon,
        color: colors.fg,
        size: iconSize,
      ),
    );
  }

  Widget _logoutTile({
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD6D9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE8757C),
            width: 1.15,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFB5121B),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ausloggen',
                style: TextStyle(
                  color: Color(0xFFB5121B),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFB5121B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveActionsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Aktive Aktionen',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _popupActionRow(
                title: 'Rabattierte Artikel',
                subtitle: 'Aktive Deals und Angebote verwalten',
                icon: Icons.local_offer_rounded,
                tone: _DashboardTone.action,
                onTap: () {
                  Navigator.pop(context);
                  _openDiscountActionsPage(
                    context,
                    shopName: context
                        .read<MerchantDashboardController>()
                        .businessName,
                  );
                },
              ),
              _popupActionRow(
                title: 'Stempelkarten',
                subtitle: 'Aktive Treuekarten',
                icon: Icons.style_rounded,
                tone: _DashboardTone.system,
                onTap: () {
                  Navigator.pop(context);
                  _openStampPage(context);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Hier siehst du die wichtigsten aktiven Systeme.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _popupActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required _DashboardTone tone,
    required VoidCallback onTap,
  }) {
    final colors = _toneColors(tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _iconBox(
              icon: icon,
              colors: colors,
              size: 42,
              iconSize: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  _ToneColors _toneColors(_DashboardTone tone) {
    switch (tone) {
      case _DashboardTone.system:
        return const _ToneColors(
          bg: Color(0xFFFFD36A),
          fg: Color(0xFF5C3900),
          border: Color(0xFFD79A25),
        );

      case _DashboardTone.action:
        return const _ToneColors(
          bg: Color(0xFFFFD6D9),
          fg: Color(0xFFB5121B),
          border: Color(0xFFE8757C),
        );

      case _DashboardTone.neutral:
        return const _ToneColors(
          bg: Color(0xFFE5D2AF),
          fg: Color(0xFF2E2518),
          border: Color(0xFFC8A96A),
        );
    }
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

  void _openFreeItemDealsPage(
      BuildContext context, {
        required String shopName,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantFreeItemDealsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
        ),
      ),
    );
  }

  void _openDiscountActionsPage(
      BuildContext context, {
        required String shopName,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantDiscountActionsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
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
          create: (_) => MerchantPointsController()
            ..loadPointsSystem(widget.merchantId),
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

  void _openBundleDealsPage(
      BuildContext context, {
        required String shopName,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantBundleDealsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
        ),
      ),
    );
  }

  void _openHappyHourDealsPage(
    BuildContext context, {
    required String shopName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantHappyHourDealsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
        ),
      ),
    );
  }

  void _openCustomPostDealsPage(
    BuildContext context, {
    required String shopName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantCustomPostDealsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
        ),
      ),
    );
  }

  void _openRescueDealsPage(
    BuildContext context, {
    required String shopName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantRescueDealsPage(
          merchantId: widget.merchantId,
          shopName: shopName,
        ),
      ),
    );
  }
}

enum _DashboardTone {
  system,
  action,
  neutral,
}

class _ToneColors {
  const _ToneColors({
    required this.bg,
    required this.fg,
    required this.border,
  });

  final Color bg;
  final Color fg;
  final Color border;
}