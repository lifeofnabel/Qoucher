import 'package:flutter/material.dart';
import 'package:qoucher/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:qoucher/features/auth/presentation/pages/login_page.dart';
import 'package:qoucher/features/auth/presentation/pages/register_page.dart';
import 'package:qoucher/features/public_home/presentation/pages/merchant_detail_page.dart';
import 'package:qoucher/features/public_home/presentation/pages/deals_pages.dart';
import 'package:qoucher/features/public_home/presentation/pages/home_page.dart';
import 'package:qoucher/features/splash/presentation/pages/splash_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/loyalty_wallet_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_activity_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_qr_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/my_rewards_page.dart';
import 'package:qoucher/features/user_dashboard/presentation/pages/user_dashboard_page.dart';
import 'package:qoucher/features/welcome/presentation/pages/admin.dart';
import 'package:qoucher/features/welcome/presentation/pages/welcome_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_actions_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_create_action_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_dashboard_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_points_system_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_profile_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_qr_scanner_page.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_rewards_page.dart';
import 'package:qoucher/router/route_names.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_dashboard_controller.dart';
import 'package:qoucher/features/merchant_dashboard/data/repositories/merchant_dashboard_repository.dart';

import '../features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import '../features/merchant_dashboard/domain/usecases/get_merchant_dashboard_data.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = _readArgs(settings.arguments);

    switch (settings.name) {
      case RouteNames.welcome:
        return _buildRoute(const WelcomePage(), settings);

      case RouteNames.splash:
        return _buildRoute(
          SplashPage(
            onInitializationComplete: (context) async {
              Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
            },
          ),
          settings,
        );

      case RouteNames.login:
        return _buildRoute(const LoginPage(), settings);

      case RouteNames.register:
        return _buildRoute(const RegisterPage(), settings);

      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);

      case RouteNames.home:
        return _buildRoute(const PublicHomePage(), settings);

      case RouteNames.deals:
        return _buildRoute(const PublicDealsPage(), settings);

      case RouteNames.merchantDetail:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Merchant Detail braucht merchantId.',
        );
        return _buildRoute(
          MerchantDetailsPage(merchantId: merchantId),
          settings,
        );

      case RouteNames.userDashboard:
        final userId = _requireStringArg(
          args,
          key: 'userId',
          fallbackMessage: 'User Dashboard braucht userId.',
        );
        return _buildRoute(
          UserDashboardPage(userId: userId),
          settings,
        );

      case RouteNames.myQr:
        final userId = _requireStringArg(
          args,
          key: 'userId',
          fallbackMessage: 'Mein QR braucht userId.',
        );
        return _buildRoute(
          MyQrPage(userId: userId),
          settings,
        );

      case RouteNames.myRewards:
        final userId = _requireStringArg(
          args,
          key: 'userId',
          fallbackMessage: 'Meine Rewards brauchen userId.',
        );
        return _buildRoute(
          MyRewardsPage(userId: userId),
          settings,
        );

      case RouteNames.myActivity:
        final userId = _requireStringArg(
          args,
          key: 'userId',
          fallbackMessage: 'Meine Aktivität braucht userId.',
        );
        return _buildRoute(
          MyActivityPage(userId: userId),
          settings,
        );

      case RouteNames.loyaltyWallet:
        final userId = _requireStringArg(
          args,
          key: 'userId',
          fallbackMessage: 'Loyalty Wallet braucht userId.',
        );
        return _buildRoute(
          LoyaltyWalletPage(userId: userId),
          settings,
        );

      case RouteNames.merchantDashboard:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Merchant Dashboard braucht merchantId.',
        );
        final repository = MerchantDashboardRepository();

        return _buildRoute(
          ChangeNotifierProvider(
            create: (_) => MerchantDashboardController(
              getMerchantDashboardData: GetMerchantDashboardData(repository),
              getActiveActions: GetActiveActions(repository),
            ),
            child: MerchantDashboardPage(
              merchantId: merchantId,
            ),
          ),
          settings,
        );

      case RouteNames.merchantProfile:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Merchant Profil braucht merchantId.',
        );
        return _buildRoute(
          MerchantProfilePage(merchantId: merchantId),
          settings,
        );

      case RouteNames.manageDeals:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Deals verwalten braucht merchantId.',
        );
        return _buildRoute(
          MerchantActionsPage(merchantId: merchantId),
          settings,
        );

      case RouteNames.manageRewards:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Rewards verwalten braucht merchantId.',
        );
        return _buildRoute(
          MerchantRewardsPage(merchantId: merchantId),
          settings,
        );

      case RouteNames.loyaltySettings:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Loyalty Einstellungen brauchen merchantId.',
        );
        return _buildRoute(
          MerchantPointsSystemPage(merchantId: merchantId),
          settings,
        );

      case RouteNames.admin:
        return _buildRoute(const AdminPage(), settings);

      case RouteNames.scanQr:
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'QR scannen braucht merchantId.',
        );
        final pointsPerEuro = _readDoubleArg(args, key: 'pointsPerEuro') ?? 1.0;

        return _buildRoute(
          MerchantQrScannerPage(
            merchantId: merchantId,
            pointsPerEuro: pointsPerEuro,
          ),
          settings,
        );

      case RouteNames.profile:
        return _buildRoute(
          const _PlaceholderPage(
            title: 'Profil',
            subtitle: 'User-Profilseite kommt als Nächstes.',
          ),
          settings,
        );

      case '/merchant-create-action':
        final merchantId = _requireStringArg(
          args,
          key: 'merchantId',
          fallbackMessage: 'Create Action braucht merchantId.',
        );
        final shopName = _requireStringArg(
          args,
          key: 'shopName',
          fallbackMessage: 'Create Action braucht shopName.',
        );

        return _buildRoute(
          MerchantCreateActionPage(
            merchantId: merchantId,
            shopName: shopName,
          ),
          settings,
        );

      default:
        return _buildRoute(
          const _UnknownRoutePage(),
          settings,
        );
    }
  }

  static Map<String, dynamic> _readArgs(Object? arguments) {
    if (arguments is Map<String, dynamic>) return arguments;
    return <String, dynamic>{};
  }

  static String _requireStringArg(
      Map<String, dynamic> args, {
        required String key,
        required String fallbackMessage,
      }) {
    final value = args[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw ArgumentError(fallbackMessage);
  }

  static double? _readDoubleArg(
      Map<String, dynamic> args, {
        required String key,
      }) {
    final value = args[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static MaterialPageRoute _buildRoute(
      Widget page,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  static Future<T?> pushNamed<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      BuildContext context,
      String routeName, {
        TO? result,
        Object? arguments,
      }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFD9F2D0),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF244D2C).withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 38,
                  color: Color(0xFF244D2C),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF244D2C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFF244D2C).withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'Seite nicht gefunden',
      subtitle: 'Diese Route existiert noch nicht oder wurde falsch aufgerufen.',
    );
  }
}