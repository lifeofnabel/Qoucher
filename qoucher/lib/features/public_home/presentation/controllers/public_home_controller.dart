import 'package:flutter/material.dart';

abstract class PublicHomeRepositoryContract {
  Future<List<Map<String, dynamic>>> getPublicDeals({
    String? category,
    String? area,
    String? query,
  });

  Future<List<Map<String, dynamic>>> getFeaturedShops();

  Future<Map<String, dynamic>?> getMerchantDetails(String merchantId);
}

class PublicHomeController extends ChangeNotifier {
  PublicHomeController({
    required PublicHomeRepositoryContract repository,
  }) : _repository = repository;

  final PublicHomeRepositoryContract _repository;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> deals = [];
  List<Map<String, dynamic>> featuredShops = [];

  String selectedCategory = '';
  String selectedArea = '';
  String searchQuery = '';

  Future<void> loadHome() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      deals = await _repository.getPublicDeals(
        category: selectedCategory.isEmpty ? null : selectedCategory,
        area: selectedArea.isEmpty ? null : selectedArea,
        query: searchQuery.isEmpty ? null : searchQuery,
      );

      featuredShops = await _repository.getFeaturedShops();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getMerchantDetails(String merchantId) {
    return _repository.getMerchantDetails(merchantId);
  }

  Future<void> applyFilters({
    String? category,
    String? area,
    String? query,
  }) async {
    selectedCategory = category ?? selectedCategory;
    selectedArea = area ?? selectedArea;
    searchQuery = query ?? searchQuery;
    await loadHome();
  }

  void clearFilters() {
    selectedCategory = '';
    selectedArea = '';
    searchQuery = '';
    notifyListeners();
  }
}