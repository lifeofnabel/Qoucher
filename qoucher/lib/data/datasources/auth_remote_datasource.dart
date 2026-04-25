class AuthRemoteDatasource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool isMerchant,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Bitte alle Felder ausfüllen.');
    }

    if (!email.contains('@')) {
      throw Exception('Ungültige E-Mail.');
    }

    if (password.trim().length < 6) {
      throw Exception('Passwort zu kurz.');
    }

    return {
      'success': true,
      'message': isMerchant
          ? 'Merchant erfolgreich eingeloggt.'
          : 'Kunde erfolgreich eingeloggt.',
      'user': {
        'id': 'user_001',
        'firstName': isMerchant ? 'Merchant Demo' : 'Nutzer Demo',
        'username': isMerchant ? 'merchant_demo' : 'kunde_demo',
        'email': email.trim(),
        'role': isMerchant ? 'merchant' : 'customer',
      },
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required bool isMerchant,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw Exception('Bitte alle Felder ausfüllen.');
    }

    if (name.trim().length < 2) {
      throw Exception('Name ist zu kurz.');
    }

    if (!email.contains('@')) {
      throw Exception('Ungültige E-Mail.');
    }

    if (password.trim().length < 6) {
      throw Exception('Passwort muss mindestens 6 Zeichen haben.');
    }

    return {
      'success': true,
      'message': isMerchant
          ? 'Merchant-Konto erfolgreich erstellt.'
          : 'Konto erfolgreich erstellt.',
      'user': {
        'id': 'user_002',
        'firstName': name.trim(),
        'username': name.trim().toLowerCase().replaceAll(' ', '_'),
        'email': email.trim(),
        'role': isMerchant ? 'merchant' : 'customer',
      },
    };
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (email.trim().isEmpty) {
      throw Exception('Bitte E-Mail eingeben.');
    }

    if (!email.contains('@')) {
      throw Exception('Ungültige E-Mail.');
    }

    return {
      'success': true,
      'message': 'Passwort-Link wurde gesendet.',
    };
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}