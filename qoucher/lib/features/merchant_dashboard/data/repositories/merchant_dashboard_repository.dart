import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_actions_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_dashboard_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_items_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_loyalty_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_rewards_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/datasources/merchant_scans_remote_datasource.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_item_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_points_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_reward_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_stamp_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/scanned_customer_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantDashboardRepository implements MerchantDashboardRepositoryContract {
  MerchantDashboardRepository({
    MerchantDashboardRemoteDatasource? dashboardDatasource,
    MerchantActionsRemoteDatasource? actionsDatasource,
    MerchantItemsRemoteDatasource? itemsDatasource,
    MerchantRewardsRemoteDatasource? rewardsDatasource,
    MerchantLoyaltyRemoteDatasource? loyaltyDatasource,
    MerchantScansRemoteDatasource? scansDatasource,
  })  : _dashboardDatasource =
      dashboardDatasource ?? MerchantDashboardRemoteDatasource(),
        _actionsDatasource =
            actionsDatasource ?? MerchantActionsRemoteDatasource(),
        _itemsDatasource = itemsDatasource ?? MerchantItemsRemoteDatasource(),
        _rewardsDatasource =
            rewardsDatasource ?? MerchantRewardsRemoteDatasource(),
        _loyaltyDatasource =
            loyaltyDatasource ?? MerchantLoyaltyRemoteDatasource(),
        _scansDatasource = scansDatasource ?? MerchantScansRemoteDatasource();

  final MerchantDashboardRemoteDatasource _dashboardDatasource;
  final MerchantActionsRemoteDatasource _actionsDatasource;
  final MerchantItemsRemoteDatasource _itemsDatasource;
  final MerchantRewardsRemoteDatasource _rewardsDatasource;
  final MerchantLoyaltyRemoteDatasource _loyaltyDatasource;
  final MerchantScansRemoteDatasource _scansDatasource;

  @override
  Future<Map<String, dynamic>?> getMerchantProfile(String merchantId) {
    return _dashboardDatasource.getMerchantProfile(merchantId);
  }

  @override
  Future<int> getActiveActionsCount(String merchantId) {
    return _dashboardDatasource.getActiveActionsCount(merchantId);
  }

  @override
  Future<int> getArchivedActionsCount(String merchantId) {
    return _dashboardDatasource.getArchivedActionsCount(merchantId);
  }

  @override
  Future<int> getScannedTodayCount(String merchantId) {
    return _dashboardDatasource.getScannedTodayCount(merchantId);
  }

  @override
  Future<Map<String, dynamic>> getDashboardOverview(String merchantId) {
    return _dashboardDatasource.getDashboardOverview(merchantId);
  }

  @override
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
  }) {
    return _actionsDatasource.createAction(
      merchantId: merchantId,
      shopName: shopName,
      type: type,
      title: title,
      subtitle: subtitle,
      description: description,
      status: status,
      isVisible: isVisible,
      imageUrl: imageUrl,
      linkedItemId: linkedItemId,
      rules: rules,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  @override
  Future<List<MerchantActionModel>> getMerchantActions(
      String merchantId, {
        String? status,
        String? type,
      }) async {
    final rawList = await _actionsDatasource.getMerchantActions(
      merchantId,
      status: status,
      type: type,
    );

    return rawList.map(MerchantActionModel.fromMap).toList();
  }

  @override
  Future<List<MerchantActionModel>> getActiveActions(String merchantId) {
    return getMerchantActions(merchantId, status: 'active');
  }

  @override
  Future<List<MerchantActionModel>> getArchivedActions(String merchantId) {
    return getMerchantActions(merchantId, status: 'archived');
  }

  @override
  Future<List<MerchantActionModel>> getPausedActions(String merchantId) {
    return getMerchantActions(merchantId, status: 'paused');
  }

  @override
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
      }) {
    return _actionsDatasource.updateAction(
      actionId,
      title: title,
      subtitle: subtitle,
      description: description,
      imageUrl: imageUrl,
      linkedItemId: linkedItemId,
      rules: rules,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  @override
  Future<void> activateAction(String actionId) {
    return _actionsDatasource.activateAction(actionId);
  }

  @override
  Future<void> pauseAction(String actionId) {
    return _actionsDatasource.pauseAction(actionId);
  }

  @override
  Future<void> archiveAction(String actionId) {
    return _actionsDatasource.archiveAction(actionId);
  }

  @override
  Future<String> createItem({
    required String merchantId,
    required String title,
    required String description,
    required double originalPrice,
    required String imageUrl,
    required String category,
    bool isActive = true,
  }) {
    return _itemsDatasource.createItem(
      merchantId: merchantId,
      title: title,
      description: description,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      category: category,
      isActive: isActive,
    );
  }

  @override
  Future<List<MerchantItemModel>> getMerchantItems(String merchantId) async {
    final rawList = await _itemsDatasource.getMerchantItems(merchantId);
    return rawList.map(MerchantItemModel.fromMap).toList();
  }

  @override
  Future<void> updateItem(
      String itemId, {
        String? title,
        String? description,
        double? originalPrice,
        String? imageUrl,
        String? category,
        bool? isActive,
      }) {
    return _itemsDatasource.updateItem(
      itemId,
      title: title,
      description: description,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      category: category,
      isActive: isActive,
    );
  }

  @override
  Future<void> setItemActive(String itemId, bool isActive) {
    return _itemsDatasource.setItemActive(itemId, isActive);
  }

  @override
  Future<String> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    String? linkedItemId,
    int? requiredPoints,
    Map<String, dynamic>? conditions,
    bool isActive = true,
  }) {
    return _rewardsDatasource.createReward(
      merchantId: merchantId,
      title: title,
      description: description,
      rewardType: rewardType,
      linkedItemId: linkedItemId,
      requiredPoints: requiredPoints,
      conditions: conditions,
      isActive: isActive,
    );
  }

  @override
  Future<List<MerchantRewardModel>> getMerchantRewards(String merchantId) async {
    final rawList = await _rewardsDatasource.getMerchantRewards(merchantId);
    return rawList.map(MerchantRewardModel.fromMap).toList();
  }

  @override
  Future<void> updateReward(
      String rewardId, {
        String? title,
        String? description,
        String? rewardType,
        String? linkedItemId,
        int? requiredPoints,
        Map<String, dynamic>? conditions,
        bool? isActive,
      }) {
    return _rewardsDatasource.updateReward(
      rewardId,
      title: title,
      description: description,
      rewardType: rewardType,
      linkedItemId: linkedItemId,
      requiredPoints: requiredPoints,
      conditions: conditions,
      isActive: isActive,
    );
  }

  @override
  Future<void> setRewardActive(String rewardId, bool isActive) {
    return _rewardsDatasource.setRewardActive(rewardId, isActive);
  }

  @override
  Future<void> savePointsProgram({
    required String merchantId,
    required bool isEnabled,
    required double pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
  }) {
    return _loyaltyDatasource.savePointsProgram(
      merchantId: merchantId,
      isEnabled: isEnabled,
      pointsPerEuro: pointsPerEuro,
      boosterConfig: boosterConfig,
    );
  }

  @override
  Future<void> saveStampProgram({
    required String merchantId,
    required bool isEnabled,
    required String stampCardName,
    required int requiredStamps,
    Map<String, dynamic>? conditions,
  }) {
    return _loyaltyDatasource.saveStampProgram(
      merchantId: merchantId,
      isEnabled: isEnabled,
      stampCardName: stampCardName,
      requiredStamps: requiredStamps,
      conditions: conditions,
    );
  }

  @override
  Future<List<dynamic>> getMerchantPrograms(String merchantId) async {
    final rawList = await _loyaltyDatasource.getMerchantPrograms(merchantId);

    return rawList.map((map) {
      final programType = (map['programType'] ?? '') as String;

      if (programType == 'points') {
        return MerchantPointsProgramModel.fromMap(map);
      }

      return MerchantStampProgramModel.fromMap(map);
    }).toList();
  }

  @override
  Future<MerchantPointsProgramModel?> getPointsProgram(String merchantId) async {
    final raw = await _loyaltyDatasource.getPointsProgram(merchantId);
    if (raw == null) return null;
    return MerchantPointsProgramModel.fromMap(raw);
  }

  @override
  Future<void> toggleProgram(String documentId, bool isEnabled) {
    return _loyaltyDatasource.toggleProgram(documentId, isEnabled);
  }

  @override
  Future<ScannedCustomerModel?> findCustomerByLiveCode(String liveCode) async {
    final raw = await _scansDatasource.findCustomerByLiveCode(liveCode);
    if (raw == null) return null;
    return ScannedCustomerModel.fromMap(raw);
  }

  @override
  Future<void> addPointsFromAmount({
    required String merchantId,
    required String customerId,
    required double amount,
    required double pointsPerEuro,
    String? comment,
  }) {
    return _scansDatasource.addPointsFromAmount(
      merchantId: merchantId,
      customerId: customerId,
      amount: amount,
      pointsPerEuro: pointsPerEuro,
      comment: comment,
    );
  }

  @override
  Future<void> addStamp({
    required String merchantId,
    required String customerId,
    required String stampProgramId,
    String? comment,
  }) {
    return _scansDatasource.addStamp(
      merchantId: merchantId,
      customerId: customerId,
      stampProgramId: stampProgramId,
      comment: comment,
    );
  }

  @override
  Future<void> redeemReward({
    required String merchantId,
    required String customerId,
    required String rewardId,
    String? comment,
  }) {
    return _scansDatasource.redeemReward(
      merchantId: merchantId,
      customerId: customerId,
      rewardId: rewardId,
      comment: comment,
    );
  }

  @override
  Future<List<MerchantScanModel>> getScannedHistory(String merchantId) async {
    final rawList = await _scansDatasource.getScannedHistory(merchantId);
    return rawList.map(MerchantScanModel.fromMap).toList();
  }

  @override
  Future<List<MerchantScanModel>> getTodayScans(String merchantId) async {
    final rawList = await _scansDatasource.getTodayScans(merchantId);
    return rawList.map(MerchantScanModel.fromMap).toList();
  }
}