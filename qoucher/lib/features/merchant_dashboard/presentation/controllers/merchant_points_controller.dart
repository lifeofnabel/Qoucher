import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_points_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantPointsController extends ChangeNotifier {
  MerchantPointsController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  MerchantPointsProgramModel? pointsProgram;

  Future<void> loadPointsProgram(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pointsProgram = await _repository.getPointsProgram(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePointsProgram({
    required String merchantId,
    required bool isEnabled,
    required double pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.savePointsProgram(
        merchantId: merchantId,
        isEnabled: isEnabled,
        pointsPerEuro: pointsPerEuro,
        boosterConfig: boosterConfig,
      );

      pointsProgram = await _repository.getPointsProgram(merchantId);
      successMessage = 'Punktesystem gespeichert.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> togglePointsProgram({
    required String merchantId,
    required String documentId,
    required bool isEnabled,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.toggleProgram(documentId, isEnabled);
      pointsProgram = await _repository.getPointsProgram(merchantId);
      successMessage = isEnabled
          ? 'Punktesystem aktiviert.'
          : 'Punktesystem deaktiviert.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}