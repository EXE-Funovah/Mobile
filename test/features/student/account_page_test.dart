import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mascoteach_mobile/data/api/user_api.dart';
import 'package:mascoteach_mobile/features/auth/providers/user_profile_provider.dart';
import 'package:mascoteach_mobile/features/quiz/providers/documents_provider.dart';
import 'package:mascoteach_mobile/features/student/pages/account_page.dart';

class _FakeDocumentsController extends DocumentsController {
  _FakeDocumentsController();

  @override
  Future<void> refresh() async {
    state = const DocumentsState(items: []);
  }
}

Widget _app(UserProfile user) {
  final router = GoRouter(
    initialLocation: '/account',
    routes: [
      GoRoute(path: '/account', builder: (context, state) => const AccountPage()),
    ],
  );

  return ProviderScope(
    overrides: [
      userProfileProvider.overrideWith((ref) async => user),
      documentsProvider.overrideWith((ref) => _FakeDocumentsController()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('email row truncates long content with ellipsis instead of wrapping', (
    tester,
  ) async {
    const email = 'adwardblowurmind@gmail.com';
    const user = UserProfile(
      id: 1,
      fullName: 'Armpit Lover',
      email: email,
      role: 'Student',
      subscriptionTier: 'Freemium',
      createdAt: null,
      authenticator: 'Local',
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_app(user));
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(find.text('Email'));
    final value = tester.widget<Text>(find.text(email));

    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
    expect(value.softWrap, isFalse);
  });
}
