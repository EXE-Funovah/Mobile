import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mascoteach_mobile/features/auth/pages/email_verification_pending_page.dart';
import 'package:mascoteach_mobile/features/auth/pages/register_page.dart';
import 'package:mascoteach_mobile/features/auth/providers/auth_provider.dart';

GoRouter _router(AuthController controller) {
  return GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const Scaffold(body: Text('login page'))),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/verify-email-pending',
        builder: (_, state) => EmailVerificationPendingPage(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
    ],
  );
}

Widget _wrap(AuthController controller) {
  return ProviderScope(
    overrides: [authProvider.overrideWith((ref) => controller)],
    child: MaterialApp.router(routerConfig: _router(controller)),
  );
}

void main() {
  testWidgets('successful register sends user to verification pending screen', (
    tester,
  ) async {
    final controller = AuthController(
      bootstrapOnInit: false,
      registerRequest: ({
        required String fullName,
        required String email,
        required String password,
        required String role,
      }) async {},
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'student@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.ensureVisible(find.text('Tạo tài khoản').last);
    await tester.tap(find.text('Tạo tài khoản').last);
    await tester.pumpAndSettle();

    expect(find.text('Kiểm tra email của bạn'), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);
  });

  testWidgets('verification pending screen can resend verification email', (
    tester,
  ) async {
    var resentEmail = '';

    final controller = AuthController(
      bootstrapOnInit: false,
      resendVerificationRequest: ({required String email}) async {
        resentEmail = email;
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(
          home: EmailVerificationPendingPage(email: 'student@example.com'),
        ),
      ),
    );

    await tester.tap(find.text('Gửi lại email xác thực'));
    await tester.pump();

    expect(resentEmail, 'student@example.com');
  });
}
