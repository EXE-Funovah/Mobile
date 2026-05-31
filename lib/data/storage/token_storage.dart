import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getToken() => _storage.read(key: ApiConstants.tokenKey);
  Future<void> setToken(String token) =>
      _storage.write(key: ApiConstants.tokenKey, value: token);
  Future<void> clear() => _storage.delete(key: ApiConstants.tokenKey);
}
