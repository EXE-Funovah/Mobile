import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/features/student/pages/payment_page.dart';

void main() {
  testWidgets('payment page hides in-development payment badges', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PaymentPage(planId: 'monthly')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sắp có'), findsNothing);
  });
}
