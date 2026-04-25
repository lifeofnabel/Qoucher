import 'package:flutter/material.dart';

abstract class UserDashboardRepositoryContract {
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  Future<List<Map<String, dynamic>>> getUserRewards(String userId);
  Future<List<Map<String, dynamic>>> getUserActivities(String userId);
  Future<Map<String, dynamic>?> getUserQrData(String userId);
  Future<List<Map<String, dynamic>>> getUserLoyaltyWallet(String userId);
}

class UserDashboardController extends ChangeNotifier {
  UserDashboardController({
    required UserDashboardRepositoryContract repository,
  }) : _repository = repository;

  final UserDashboardRepositoryContract _repository;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? profile;
  Map<String, dynamic>? qrData;

  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> activities = [];
  List<Map<String, dynamic>> loyaltyWallet = [];

  Future<void> loadDashboard(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _repository.getUserProfile(userId);
      qrData = await _repository.getUserQrData(userId);
      rewards = await _repository.getUserRewards(userId);
      activities = await _repository.getUserActivities(userId);
      loyaltyWallet = await _repository.getUserLoyaltyWallet(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRewards(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      rewards = await _repository.getUserRewards(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActivities(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      activities = await _repository.getUserActivities(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQrData(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      qrData = await _repository.getUserQrData(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLoyaltyWallet(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      loyaltyWallet = await _repository.getUserLoyaltyWallet(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get firstName =>
      (profile?['firstName'] ?? profile?['username'] ?? 'User').toString();

  int get totalPoints => (profile?['points'] ?? 0) as int;
}