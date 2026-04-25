import 'dart:convert';

class QrHelper {
  QrHelper._();

  static String buildUserQr({
    required String userId,
    required String role,
  }) {
    final payload = {
      'type': 'qoucher_user',
      'userId': userId,
      'role': role,
    };

    return jsonEncode(payload);
  }

  static Map<String, dynamic>? parseQr(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static bool isValidUserQr(String rawValue) {
    final data = parseQr(rawValue);
    if (data == null) return false;

    return data['type'] == 'qoucher_user' &&
        data['userId'] != null &&
        data['role'] != null;
  }

  static String? extractUserId(String rawValue) {
    final data = parseQr(rawValue);
    if (data == null) return null;

    return data['userId']?.toString();
  }

  static String? extractRole(String rawValue) {
    final data = parseQr(rawValue);
    if (data == null) return null;

    return data['role']?.toString();
  }
}