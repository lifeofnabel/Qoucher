import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantProfileController extends ChangeNotifier {
  MerchantProfileController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  Map<String, dynamic>? profile;

  Future<void> loadProfile(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
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

  String get businessName {
    return (profile?['businessName'] ??
        profile?['firstName'] ??
        profile?['username'] ??
        'Mein Shop')
        .toString();
  }

  String get contactName => (profile?['contactName'] ?? '').toString();
  String get email => (profile?['email'] ?? '').toString();
  String get phone => (profile?['phone'] ?? '').toString();
  String get address => (profile?['address'] ?? '').toString();
  String get description => (profile?['description'] ?? '').toString();
  String get logoUrl => (profile?['logoUrl'] ?? '').toString();

  List<String> get categories {
    final raw = profile?['categories'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}