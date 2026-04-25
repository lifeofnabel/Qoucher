import 'package:flutter/foundation.dart';

class DebugHelper {
  DebugHelper._();

  static void log(String message, {String tag = 'QOUCHER'}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('[QOUCHER ✅] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[QOUCHER ⚠️] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[QOUCHER ❌] $message');
      if (error != null) {
        debugPrint('[QOUCHER ERROR DETAIL] $error');
      }
    }
  }

  static void object(String title, Object object) {
    if (kDebugMode) {
      debugPrint('[QOUCHER OBJECT] $title: $object');
    }
  }
}