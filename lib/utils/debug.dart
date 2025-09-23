import 'package:flutter/foundation.dart';

class DebugX {
  static void console(Object message) {
    if (kDebugMode) {
      print(message);
    }
  }
}