import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/create_merchant_action.dart';

class MerchantCreateActionController extends ChangeNotifier {
  MerchantCreateActionController({
    required CreateMerchantAction createMerchantAction,
  }) : _createMerchantAction = createMerchantAction;

  final CreateMerchantAction _createMerchantAction;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  String? createdActionId;

  Future<bool> createAction({
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
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      createdActionId = await _createMerchantAction(
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

      successMessage = 'Aktion erfolgreich erstellt.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}