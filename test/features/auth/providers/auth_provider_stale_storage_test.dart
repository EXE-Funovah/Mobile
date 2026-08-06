import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/auth_api.dart';
import 'package:mascoteach_mobile/features/auth/providers/auth_provider.dart';
import 'package:mascoteach_mobile/data/models/user.dart';

void main() {
  test('new auth result clears stale stored display name and role when absent', () async {
    const validJwt =
        'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjQxMDI0NDQ4MDB9.signature';

    String? storedToken = validJwt;
    String? storedName = 'Old User';
    String? storedRole = 'Teacher';

    final controller = AuthController(
      bootstrapOnInit: false,
      loginRequest: ({required String email, required String password}) async {
        return AuthResult(token: validJwt);
      },
      tokenReader: () async => storedToken,
      displayNameReader: () async => storedName,
      roleReader: () async => storedRole,
      tokenWriter: (token) async => storedToken = token,
      displayNameWriter: (name) async => storedName = name,
      roleWriter: (role) async => storedRole = role,
      clearStorage: () async {
        storedToken = null;
        storedName = null;
        storedRole = null;
      },
    );

    final ok = await controller.login('new@example.com', 'secret123');

    expect(ok, isTrue);
    expect(controller.state.token, validJwt);
    expect(controller.state.displayName, isNull);
    expect(controller.state.role, UserRole.unknown);
    expect(storedName, '');
    expect(storedRole, '');

    final bootstrapped = AuthController(
      loginRequest: ({required String email, required String password}) async {
        throw UnimplementedError();
      },
      tokenReader: () async => storedToken,
      displayNameReader: () async => storedName,
      roleReader: () async => storedRole,
      tokenWriter: (token) async => storedToken = token,
      displayNameWriter: (name) async => storedName = name,
      roleWriter: (role) async => storedRole = role,
      clearStorage: () async {
        storedToken = null;
        storedName = null;
        storedRole = null;
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bootstrapped.state.token, validJwt);
    expect(bootstrapped.state.displayName, isNull);
    expect(bootstrapped.state.role, UserRole.unknown);
  });
}
