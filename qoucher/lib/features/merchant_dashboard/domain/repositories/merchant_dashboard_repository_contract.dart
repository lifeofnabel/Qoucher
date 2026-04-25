import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_item_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_points_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_reward_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_stamp_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/scanned_customer_model.dart';

abstract class MerchantDashboardRepositoryContract {
  Future<Map<String, dynamic>?> getMerchantProfile(String merchantId);

  Future<int> getActiveActionsCount(String merchantId);
  Future<int> getArchivedActionsCount(String merchantId);
  Future<int> getScannedTodayCount(String merchantId);

  Future<Map<String, dynamic>> getDashboardOverview(String merchantId);

  Future<String> createAction({
    required String merchantId,
    required String shopName,
    required String type,
    required String title,
    required String subtitle,
    required String description,
    required String status,
    required bool isVisible,
    String? imageUrl,
    String? linkedItemId,
    Map<String, dynamic>? rules,
    DateTime? startsAt,
    DateTime? endsAt,
  });

  Future<List<MerchantActionModel>> getMerchantActions(
      String merchantId, {
        String? status,
        String? type,
      });

  Future<List<MerchantActionModel>> getActiveActions(String merchantId);
  Future<List<MerchantActionModel>> getArchivedActions(String merchantId);
  Future<List<MerchantActionModel>> getPausedActions(String merchantId);

  Future<void> updateAction(
      String actionId, {
        String? title,
        String? subtitle,
        String? description,
        String? imageUrl,
        String? linkedItemId,
        Map<String, dynamic>? rules,
        DateTime? startsAt,
        DateTime? endsAt,
      });

  Future<void> activateAction(String actionId);
  Future<void> pauseAction(String actionId);
  Future<void> archiveAction(String actionId);

  Future<String> createItem({
    required String merchantId,
    required String title,
    required String description,
    required double originalPrice,
    required String imageUrl,
    required String category,
    bool isActive = true,
  });

  Future<List<MerchantItemModel>> getMerchantItems(String merchantId);

  Future<void> updateItem(
      String itemId, {
        String? title,
        String? description,
        double? originalPrice,
        String? imageUrl,
        String? category,
        bool? isActive,
      });

  Future<void> setItemActive(String itemId, bool isActive);

  Future<String> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    String? linkedItemId,
    int? requiredPoints,
    Map<String, dynamic>? conditions,
    bool isActive = true,
  });

  Future<List<MerchantRewardModel>> getMerchantRewards(String merchantId);

  Future<void> updateReward(
      String rewardId, {
        String? title,
        String? description,
        String? rewardType,
        String? linkedItemId,
        int? requiredPoints,
        Map<String, dynamic>? conditions,
        bool? isActive,
      });

  Future<void> setRewardActive(String rewardId, bool isActive);

  Future<void> savePointsProgram({
    required String merchantId,
    required bool isEnabled,
    required double pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
  });

  Future<void> saveStampProgram({
    required String merchantId,
    required bool isEnabled,
    required String stampCardName,
    required int requiredStamps,
    Map<String, dynamic>? conditions,
  });

  Future<List<dynamic>> getMerchantPrograms(String merchantId);
  Future<MerchantPointsProgramModel?> getPointsProgram(String merchantId);
  Future<void> toggleProgram(String documentId, bool isEnabled);

  Future<ScannedCustomerModel?> findCustomerByLiveCode(String liveCode);

  Future<void> addPointsFromAmount({
    required String merchantId,
    required String customerId,
    required double amount,
    required double pointsPerEuro,
    String? comment,
  });

  Future<void> addStamp({
    required String merchantId,
    required String customerId,
    required String stampProgramId,
    String? comment,
  });

  Future<void> redeemReward({
    required String merchantId,
    required String customerId,
    required String rewardId,
    String? comment,
  });

  Future<List<MerchantScanModel>> getScannedHistory(String merchantId);
  Future<List<MerchantScanModel>> getTodayScans(String merchantId);
}