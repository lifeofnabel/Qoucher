import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_stamp_program_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantStampController extends ChangeNotifier {
  MerchantStampController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  List<MerchantStampProgramModel> stampPrograms = [];

  Future<void> loadStampPrograms(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final programs = await _repository.getMerchantPrograms(merchantId);

      stampPrograms = programs
          .whereType<MerchantStampProgramModel>()
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
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

      await loadStampPrograms(merchantId);
      successMessage = 'Stempelkarte gespeichert.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleStampProgram({
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
      await loadStampPrograms(merchantId);
      successMessage = isEnabled
          ? 'Stempelkarte aktiviert.'
          : 'Stempelkarte deaktiviert.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> addStampToCustomer({
    required String merchantId,
    required String customerId,
    required String stampProgramId,
    String? comment,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.addStamp(
        merchantId: merchantId,
        customerId: customerId,
        stampProgramId: stampProgramId,
        comment: comment,
      );

      successMessage = 'Stempel hinzugefügt.';
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