import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/billing_api.dart';
import 'package:mascoteach_mobile/features/student/pages/payment_history_page.dart';
import 'package:mascoteach_mobile/features/student/providers/payment_history_provider.dart';

void main() {
  testWidgets('payment history page shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentHistoryProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: PaymentHistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có thanh toán nào'), findsOneWidget);
  });

  testWidgets('payment history page shows orders', (tester) async {
    final order = PaymentOrder(
      id: 1,
      orderCode: 123456,
      planCode: 'PRO_MONTHLY',
      amount: 119000,
      currency: 'VND',
      status: 'Paid',
      provider: 'PayOS',
      createdAt: DateTime(2026, 8, 5, 8, 30),
      paidAt: DateTime(2026, 8, 5, 8, 35),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentHistoryProvider.overrideWith((ref) async => [order]),
        ],
        child: const MaterialApp(home: PaymentHistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Premium tháng'), findsOneWidget);
    expect(find.text('Đã thanh toán'), findsOneWidget);
    expect(find.text('Mã đơn #123456'), findsOneWidget);
  });
}
