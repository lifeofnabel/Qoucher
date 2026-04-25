class ScannerService {
  Future<String> scanQrCode() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return 'demo_user_qr_001';
  }

  Future<Map<String, dynamic>> parseQrCode(String rawValue) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (rawValue.trim().isEmpty) {
      throw Exception('QR-Code ist leer.');
    }

    return {
      'rawValue': rawValue,
      'userId': rawValue,
      'isValid': true,
    };
  }

  Future<bool> validateQrCode(String rawValue) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return rawValue.trim().isNotEmpty;
  }
}