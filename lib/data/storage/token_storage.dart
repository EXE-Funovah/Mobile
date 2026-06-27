import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  Future<String?> getToken() => _storage.read(key: ApiConstants.tokenKey);
  Future<void> setToken(String token) =>
      _storage.write(key: ApiConstants.tokenKey, value: token);

  Future<String?> getDisplayName() =>
      _storage.read(key: 'mascoteach_display_name');
  Future<void> setDisplayName(String name) =>
      _storage.write(key: 'mascoteach_display_name', value: name);

  Future<String?> getRole() => _storage.read(key: 'mascoteach_role');
  Future<void> setRole(String role) =>
      _storage.write(key: 'mascoteach_role', value: role);

  Future<void> clear() async {
    await _storage.delete(key: ApiConstants.tokenKey);
    await _storage.delete(key: 'mascoteach_display_name');
    await _storage.delete(key: 'mascoteach_role');
  }
}
