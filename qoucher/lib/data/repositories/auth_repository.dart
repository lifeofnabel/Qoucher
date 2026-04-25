import 'package:qoucher/data/datasources/auth_remote_datasource.dart';
import 'package:qoucher/data/models/app_user.dart';

class AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepository({
    required this.remoteDatasource,
  });

  Future<AppUser> login({
    required String email,
    required String password,
    required bool isMerchant,
  }) async {
    final result = await remoteDatasource.login(
      email: email,
      password: password,
      isMerchant: isMerchant,
    );

    final userMap = result['user'] as Map<String, dynamic>?;
    if (userMap == null) {
      throw Exception('Kein Nutzer zurückgegeben.');
    }

    return AppUser.fromMap(userMap);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required bool isMerchant,
  }) async {
    final result = await remoteDatasource.register(
      name: name,
      email: email,
      password: password,
      isMerchant: isMerchant,
    );

    final userMap = result['user'] as Map<String, dynamic>?;
    if (userMap == null) {
      throw Exception('Kein Nutzer zurückgegeben.');
    }

    return AppUser.fromMap(userMap);
  }

  Future<String> forgotPassword({
    required String email,
  }) async {
    final result = await remoteDatasource.forgotPassword(email: email);
    return result['message']?.toString() ?? 'Passwort-Link wurde gesendet.';
  }

  Future<void> logout() async {
    await remoteDatasource.logout();
  }
}