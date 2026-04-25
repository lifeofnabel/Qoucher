import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_item_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_reward_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantShopController extends ChangeNotifier {
  MerchantShopController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? profile;
  List<MerchantActionModel> activeActions = [];
  List<MerchantItemModel> items = [];
  List<MerchantRewardModel> rewards = [];

  Future<void> loadShop(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _repository.getMerchantProfile(merchantId);
      activeActions = await _repository.getActiveActions(merchantId);
      items = await _repository.getMerchantItems(merchantId);
      rewards = await _repository.getMerchantRewards(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}