import 'package:flutter/material.dart';
import 'package:qoucher/core/services/auth_service.dart';
import 'package:qoucher/data/models/app_user.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isMerchant = false;
  AppUser? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isMerchant => _isMerchant;
  AppUser? get currentUser => _currentUser;

  void setMerchant(bool value) {
    _isMerchant = value;
    clearMessages();
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearInternalMessages();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
        wantsMerchantLogin: _isMerchant,
      );

      _currentUser = user;
      _successMessage = user.role == 'merchant'
          ? 'Merchant-Login erfolgreich.'
          : 'Login erfolgreich.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerCustomer({
    required String firstName,
    required String username,
    required String email,
    required String password,
    required String gender,
  }) async {
    _setLoading(true);
    _clearInternalMessages();

    try {
      if (_isMerchant) {
        _errorMessage =
        'Merchant kann sich nicht direkt registrieren. Bitte Anfrage senden.';
        return false;
      }

      final user = await _authService.registerCustomer(
        firstName: firstName,
        username: username,
        email: email,
        password: password,
        gender: gender,
      );

      _currentUser = user;
      _successMessage = 'Konto erfolgreich erstellt.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestMerchantAccess({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    String? contactName,
    String? note,
  }) async {
    _setLoading(true);
    _clearInternalMessages();

    try {
      await _authService.requestMerchantAccess(
        businessName: businessName,
        category: category,
        phone: phone,
        email: email,
        contactName: contactName,
        note: note,
      );

      _successMessage =
      'Anfrage gesendet. Wir melden uns bei dir für den Merchant-Zugang.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearInternalMessages();

    try {
      final message = await _authService.forgotPassword(email: email);
      _successMessage = message;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearInternalMessages();

    try {
      await _authService.logout();
      _currentUser = null;
      _successMessage = 'Erfolgreich ausgeloggt.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearInternalMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}