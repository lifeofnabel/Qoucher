import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_merchant_dashboard_data.dart';

class MerchantDashboardController extends ChangeNotifier {
  MerchantDashboardController({
    required GetMerchantDashboardData getMerchantDashboardData,
    required GetActiveActions getActiveActions,
  })  : _getMerchantDashboardData = getMerchantDashboardData,
        _getActiveActions = getActiveActions;

  final GetMerchantDashboardData _getMerchantDashboardData;
  final GetActiveActions _getActiveActions;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? overview;
  List<MerchantActionModel> activeActions = [];

  Future<void> loadDashboard(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      overview = await _getMerchantDashboardData(merchantId);
      activeActions = await _getActiveActions(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get businessName {
    final profile = overview?['profile'] as Map<String, dynamic>?;
    return (profile?['businessName'] ??
        profile?['firstName'] ??
        profile?['username'] ??
        'Mein Shop')
        .toString();
  }

  int get activeActionsCount => (overview?['activeActionsCount'] ?? 0) as int;
  int get archivedActionsCount =>
      (overview?['archivedActionsCount'] ?? 0) as int;
  int get scannedTodayCount => (overview?['scannedTodayCount'] ?? 0) as int;
}