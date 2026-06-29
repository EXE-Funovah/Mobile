import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/features/auth/providers/auth_provider.dart';

void main() {
  test('register creates account without authenticating the user', () async {
    var registerCalled = false;
    var loginCalled = false;

    final controller = AuthController(
      bootstrapOnInit: false,
      registerRequest: ({
        required String fullName,
        required String email,
        required String password,
        required String role,
      }) async {
        registerCalled = true;
      },
      loginRequest: ({required String email, required String password}) async {
        loginCalled = true;
        throw StateError('login should not be called after register');
      },
    );

    final ok = await controller.register(
      fullName: 'Test User',
      email: 'student@example.com',
      password: 'secret123',
      role: 'Student',
    );

    expect(ok, isTrue);
    expect(registerCalled, isTrue);
    expect(loginCalled, isFalse);
    expect(controller.state.isAuthenticated, isFalse);
    expect(controller.state.error, isNull);
  });
}
