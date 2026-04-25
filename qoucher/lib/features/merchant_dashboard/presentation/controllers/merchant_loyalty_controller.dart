import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_points_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantLoyaltyController extends ChangeNotifier {
  MerchantLoyaltyController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  MerchantPointsProgramModel? pointsProgram;
  List<dynamic> allPrograms = [];

  Future<void> loadPrograms(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pointsProgram = await _repository.getPointsProgram(merchantId);
      allPrograms = await _repository.getMerchantPrograms(merchantId);
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
      successMessage = 'Punktesystem gespeichert.';
      await loadPrograms(merchantId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveStampProgram({
    required String merchantId,
    required bool isEnabled,
    required String stampCardName,
    required int requiredStamps,
    Map<String, dynamic>? conditions,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.saveStampProgram(
        merchantId: merchantId,
        isEnabled: isEnabled,
        stampCardName: stampCardName,
        requiredStamps: requiredStamps,
        conditions: conditions,
      );
      successMessage = 'Stempelkarte gespeichert.';
      await loadPrograms(merchantId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleProgram({
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
      successMessage = 'Status aktualisiert.';
      await loadPrograms(merchantId);
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