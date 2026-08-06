import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/billing_api.dart';

final paymentHistoryProvider = FutureProvider<List<PaymentOrder>>((ref) async {
  return BillingApi.instance.getMyOrders();
});
