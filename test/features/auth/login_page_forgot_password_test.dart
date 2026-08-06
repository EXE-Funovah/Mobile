import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/features/auth/pages/login_page.dart';

void main() {
  testWidgets('forgot password sends reset email from login page', (
    tester,
  ) async {
    var requestedEmail = '';

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginPage(
            forgotPasswordRequest: ({required String email}) async {
              requestedEmail = email;
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
      find.byType(TextFormField).last,
      'student@example.com',
    );
    await tester.tap(find.text('Gửi email'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(requestedEmail, 'student@example.com');
    expect(
      find.text(
        'Nếu email tồn tại, hướng dẫn đặt lại mật khẩu đã được gửi.',
      ),
      findsOneWidget,
    );
  });
}
