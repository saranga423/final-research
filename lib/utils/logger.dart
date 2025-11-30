import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint("[LOG] $message");
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      debugPrint("[ERROR] $message");
    }
  }
}
