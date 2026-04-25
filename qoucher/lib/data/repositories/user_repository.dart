import 'package:qoucher/data/models/app_user.dart';

class UserRepository {
  Future<AppUser> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const AppUser(
      id: 'user_current_001',
      firstName: 'Nabil',
      username: 'nabil_demo',
      email: 'nabil@example.com',
      role: 'customer',
    );
  }

  Future<AppUser> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return AppUser(
      id: userId,
      firstName: 'Demo',
      username: 'demo_user',
      email: 'demo@example.com',
      role: 'customer',
    );
  }

  Future<AppUser> updateUserProfile({
    required String userId,
    required String firstName,
    required String username,
    required String email,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (firstName.trim().isEmpty) {
      throw Exception('Vorname fehlt.');
    }

    if (username.trim().isEmpty) {
      throw Exception('Username fehlt.');
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Ungültige E-Mail.');
    }

    return AppUser(
      id: userId,
      firstName: firstName.trim(),
      username: username.trim(),
      email: email.trim(),
      role: role,
    );
  }
}