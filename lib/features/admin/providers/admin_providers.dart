import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_api.dart';
import '../data/admin_models.dart';

/// Bộ lọc thời gian dùng chung (7d / 30d / 12m).
final adminRangeProvider = StateProvider<String>((_) => '30d');

final adminOverviewProvider = FutureProvider.autoDispose<AdminOverview>((ref) {
  final range = ref.watch(adminRangeProvider);
  return AdminApi.instance.overview(range: range);
});

final adminRevenueProvider = FutureProvider.autoDispose<AdminRevenue>((ref) {
  final range = ref.watch(adminRangeProvider);
  return AdminApi.instance.revenue(range: range);
});

/// Từ khoá tìm kiếm tài khoản.
final adminAccountSearchProvider = StateProvider<String>((_) => '');

final adminAccountsProvider = FutureProvider.autoDispose<AdminAccounts>((ref) {
  final s = ref.watch(adminAccountSearchProvider);
  return AdminApi.instance.accounts(search: s.isEmpty ? null : s);
});
