import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_item_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class MerchantItemsController extends ChangeNotifier {
  MerchantItemsController({
    required MerchantDashboardRepositoryContract repository,
  }) : _repository = repository;

  final MerchantDashboardRepositoryContract _repository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  List<MerchantItemModel> items = [];

  Future<void> loadItems(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      items = await _repository.getMerchantItems(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem({
    required String merchantId,
    required String title,
    required String description,
    required double originalPrice,
    required String imageUrl,
    required String category,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.createItem(
        merchantId: merchantId,
        title: title,
        description: description,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        category: category,
      );
      successMessage = 'Artikel erstellt.';
      await loadItems(merchantId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem({
    required String merchantId,
    required String itemId,
    String? title,
    String? description,
    double? originalPrice,
    String? imageUrl,
    String? category,
    bool? isActive,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.updateItem(
        itemId,
        title: title,
        description: description,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        category: category,
        isActive: isActive,
      );
      successMessage = 'Artikel aktualisiert.';
      await loadItems(merchantId);
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