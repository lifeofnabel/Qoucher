import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantAccountController extends ChangeNotifier {
  MerchantAccountController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? profile;

  Future<void> loadProfile(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _repository.getMerchantProfile(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}