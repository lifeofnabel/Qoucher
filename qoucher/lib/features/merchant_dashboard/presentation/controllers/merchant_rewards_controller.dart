import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_reward_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantRewardsController extends ChangeNotifier {
  MerchantRewardsController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  List<MerchantRewardModel> rewards = [];

  Future<void> loadRewards(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      rewards = await _repository.getMerchantRewards(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    String? linkedItemId,
    int? requiredPoints,
    Map<String, dynamic>? conditions,
    bool isActive = true,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.createReward(
        merchantId: merchantId,
        title: title,
        description: description,
        rewardType: rewardType,
        linkedItemId: linkedItemId,
        requiredPoints: requiredPoints,
        conditions: conditions,
        isActive: isActive,
      );

      successMessage = 'Reward erstellt.';
      await loadRewards(merchantId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}