import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_archived_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_create_action_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_dashboard_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_items_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_points_system_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_profile_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_qr_scanner_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_rewards_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_scanned_history_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_shop_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_stamp_system_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/scanned_customer_page.dart';

class MerchantDashboardRoutes {
  static const String dashboard = '/merchant-dashboard';
  static const String actions = '/merchant-dashboard/actions';
  static const String archivedActions = '/merchant-dashboard/archived-actions';
  static const String createAction = '/merchant-dashboard/create-action';
  static const String items = '/merchant-dashboard/items';
  static const String rewards = '/merchant-dashboard/rewards';
  static const String pointsSystem = '/merchant-dashboard/points-system';
  static const String stampSystem = '/merchant-dashboard/stamp-system';
  static const String profile = '/merchant-dashboard/profile';
  static const String qrScanner = '/merchant-dashboard/qr-scanner';
  static const String scannedHistory = '/merchant-dashboard/scanned-history';
  static const String scannedCustomer = '/merchant-dashboard/scanned-customer';
  static const String shop = '/merchant-dashboard/shop';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        final args = settings.arguments as MerchantDashboardPageArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantDashboardPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case actions:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantActionsPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case archivedActions:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantArchivedActionsPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case createAction:
        final args = settings.arguments as MerchantCreateActionPageArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantCreateActionPage(
            merchantId: args.merchantId,
            shopName: args.shopName,
          ),
          settings: settings,
        );

      case items:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantItemsPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case rewards:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantRewardsPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case pointsSystem:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantPointsSystemPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case stampSystem:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantStampSystemPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case profile:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantProfilePage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case qrScanner:
        final args = settings.arguments as MerchantQrScannerPageArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantQrScannerPage(
            merchantId: args.merchantId,
            pointsPerEuro: args.pointsPerEuro,
          ),
          settings: settings,
        );

      case scannedHistory:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantScannedHistoryPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      case scannedCustomer:
        final args = settings.arguments as ScannedCustomerPageArgs;
        return MaterialPageRoute(
          builder: (_) => ScannedCustomerPage(
            merchantId: args.merchantId,
            customerCode: args.customerCode,
            pointsPerEuro: args.pointsPerEuro,
          ),
          settings: settings,
        );

      case shop:
        final args = settings.arguments as MerchantIdArgs;
        return MaterialPageRoute(
          builder: (_) => MerchantShopPage(
            merchantId: args.merchantId,
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }
}

class MerchantIdArgs {
  final String merchantId;

  const MerchantIdArgs({
    required this.merchantId,
  });
}

class MerchantDashboardPageArgs {
  final String merchantId;

  const MerchantDashboardPageArgs({
    required this.merchantId,
  });
}

class MerchantCreateActionPageArgs {
  final String merchantId;
  final String shopName;

  const MerchantCreateActionPageArgs({
    required this.merchantId,
    required this.shopName,
  });
}

class MerchantQrScannerPageArgs {
  final String merchantId;
  final double pointsPerEuro;

  const MerchantQrScannerPageArgs({
    required this.merchantId,
    required this.pointsPerEuro,
  });
}

class ScannedCustomerPageArgs {
  final String merchantId;
  final String customerCode;
  final double pointsPerEuro;

  const ScannedCustomerPageArgs({
    required this.merchantId,
    required this.customerCode,
    required this.pointsPerEuro,
  });
}