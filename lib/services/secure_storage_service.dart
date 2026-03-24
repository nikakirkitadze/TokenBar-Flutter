import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  static Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _sessionTokenKey, value: token);
  }

  static Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionTokenKey);
  }

  static Future<void> deleteSessionToken() async {
    await _storage.delete(key: _sessionTokenKey);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
