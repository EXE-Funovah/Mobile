import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/user_api.dart';
import 'package:mascoteach_mobile/features/auth/pages/login_page.dart';
import 'package:mascoteach_mobile/features/auth/providers/auth_provider.dart';
import 'package:mascoteach_mobile/features/auth/providers/user_profile_provider.dart';

class _FakeGoogleAuthController extends AuthController {
  _FakeGoogleAuthController() : super(bootstrapOnInit: false);

  @override
  Future<bool> googleSignIn() async => true;
}

void main() {
  testWidgets('successful Google login invalidates cached user profile', (
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
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pump();

    final secondProfile = await container.read(userProfileProvider.future);
    expect(secondProfile.email, 'user2@example.com');
    expect(loadCount, 2);
  });
}
