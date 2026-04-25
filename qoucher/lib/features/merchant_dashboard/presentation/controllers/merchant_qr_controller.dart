import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/scanned_customer_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/assign_points_from_amount.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_scanned_history.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/redeem_reward.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/scan_customer_code.dart';

class MerchantQrController extends ChangeNotifier {
  MerchantQrController({
    required ScanCustomerByLiveCode scanCustomerByLiveCode,
    required AssignPointsFromAmount assignPointsFromAmount,
    required RedeemReward redeemReward,
    required GetScannedHistory getScannedHistory,
  })  : _scanCustomerByLiveCode = scanCustomerByLiveCode,
        _assignPointsFromAmount = assignPointsFromAmount,
        _redeemReward = redeemReward,
        _getScannedHistory = getScannedHistory;

  final ScanCustomerByLiveCode _scanCustomerByLiveCode;
  final AssignPointsFromAmount _assignPointsFromAmount;
  final RedeemReward _redeemReward;
  final GetScannedHistory _getScannedHistory;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? successMessage;

  ScannedCustomerModel? scannedCustomer;
  List<MerchantScanModel> scannedHistory = [];

  Future<bool> scanCustomer(String liveCode) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      scannedCustomer = await _scanCustomerByLiveCode(liveCode);

      if (scannedCustomer == null) {
        errorMessage = 'Kein Kunde mit diesem Code gefunden.';
        return false;
      }

      successMessage = 'Kunde erfolgreich gefunden.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignPoints({
    required String merchantId,
    required String customerId,
    required double amount,
    required double pointsPerEuro,
    String? comment,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _assignPointsFromAmount(
        merchantId: merchantId,
        customerId: customerId,
        amount: amount,
        pointsPerEuro: pointsPerEuro,
        comment: comment,
      );

      successMessage = 'Punkte erfolgreich gutgeschrieben.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> redeemCustomerReward({
    required String merchantId,
    required String customerId,
    required String rewardId,
    String? comment,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _redeemReward(
        merchantId: merchantId,
        customerId: customerId,
        rewardId: rewardId,
        comment: comment,
      );

      successMessage = 'Reward erfolgreich eingelöst.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadScannedHistory(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      scannedHistory = await _getScannedHistory(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearScannedCustomer() {
    scannedCustomer = null;
    notifyListeners();
  }
}