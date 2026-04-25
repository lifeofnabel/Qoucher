import 'package:qoucher/core/services/auth_service.dart';
import 'package:qoucher/router/route_names.dart';

class RouteGuard {
  RouteGuard._();

  static final AuthService _authService = AuthService.instance;

  static bool get isLoggedIn => _authService.isLoggedIn;
  static bool get isMerchant => _authService.isMerchant;
  static bool get isCustomer => _authService.isCustomer;

  static String getInitialRoute() {
    if (!isLoggedIn) {
      return RouteNames.login;
    }

    if (isMerchant) {
      return RouteNames.merchantDashboard;
    }

    return RouteNames.home;
  }

  static String redirectAfterLogin({required bool isMerchantLogin}) {
    if (isMerchantLogin) {
      return RouteNames.merchantDashboard;
    }

    return RouteNames.home;
  }

  static bool canAccessMerchantRoute() {
    return isLoggedIn && isMerchant;
  }

  static bool canAccessCustomerRoute() {
    return isLoggedIn && isCustomer;
  }

  static bool canAccessAuthenticatedRoute() {
    return isLoggedIn;
  }
}