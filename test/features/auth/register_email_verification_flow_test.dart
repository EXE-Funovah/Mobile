import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mascoteach_mobile/data/api/user_api.dart';
import 'package:mascoteach_mobile/features/auth/pages/email_verification_pending_page.dart';
import 'package:mascoteach_mobile/features/auth/pages/register_page.dart';
import 'package:mascoteach_mobile/features/auth/providers/auth_provider.dart';
import 'package:mascoteach_mobile/features/auth/providers/user_profile_provider.dart';

class _FakeGoogleAuthController extends AuthController {
  _FakeGoogleAuthController() : super(bootstrapOnInit: false);

  var googleSignInCalled = false;

  @override
  Future<bool> googleSignIn() async {
    googleSignInCalled = true;
    return true;
  }
}

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

  testWidgets('register Google button uses the real Google auth flow', (
    tester,
  ) async {
    final controller = _FakeGoogleAuthController();

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Đăng ký với Google'));
    await tester.tap(find.text('Đăng ký với Google'));
    await tester.pump();

    expect(controller.googleSignInCalled, isTrue);
  });

  testWidgets('register Google flow invalidates cached user profile', (
    tester,
  ) async {
    final controller = _FakeGoogleAuthController();
    var loadCount = 0;

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => controller),
        userProfileProvider.overrideWith((ref) async {
          loadCount++;
          return UserProfile(
            id: loadCount,
            fullName: 'User $loadCount',
            email: 'user$loadCount@example.com',
            role: 'Student',
            subscriptionTier: 'Freemium',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final firstProfile = await container.read(userProfileProvider.future);
    expect(firstProfile.email, 'user1@example.com');
    expect(loadCount, 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RegisterPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Đăng ký với Google'));
    await tester.tap(find.text('Đăng ký với Google'));
    await tester.pump();

    final secondProfile = await container.read(userProfileProvider.future);
    expect(secondProfile.email, 'user2@example.com');
    expect(loadCount, 2);
  });
}
