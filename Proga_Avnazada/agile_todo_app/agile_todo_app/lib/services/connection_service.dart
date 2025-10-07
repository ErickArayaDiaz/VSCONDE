// lib/services/connection_service.dart
import 'dart:io';

class ConnectionService {
  /// Retorna `true` si hay conexión a Internet, `false` si no.
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
