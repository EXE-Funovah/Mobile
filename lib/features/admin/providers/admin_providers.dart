import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_api.dart';
import '../data/admin_models.dart';

/// Bộ lọc thời gian dùng chung (7d / 30d / 12m).
final adminRangeProvider = StateProvider<String>((_) => '30d');

final adminOverviewProvider = FutureProvider.autoDispose<AdminOverview>((ref) {
  final range = ref.watch(adminRangeProvider);
  return AdminApi.instance.overview(range: range);
});

// ── Doanh thu ──
final adminOrderStatusProvider = StateProvider<String?>((_) => null);
final adminOrderPlanProvider = StateProvider<String?>((_) => null);

final adminBillingOrdersProvider =
    FutureProvider.autoDispose<AdminPaymentOrders>((ref) {
      final status = ref.watch(adminOrderStatusProvider);
      final plan = ref.watch(adminOrderPlanProvider);
      return AdminApi.instance.billingOrders(status: status, plan: plan);
    });

/// Webhook PayOS. filter: null=tất cả, true=đã xử lý, false=có lỗi.
final adminWebhookProcessedProvider = StateProvider<bool?>((_) => null);
final adminWebhookProvider = FutureProvider.autoDispose<AdminWebhookEvents>((
  ref,
) {
  final p = ref.watch(adminWebhookProcessedProvider);
  return AdminApi.instance.webhookEvents(
    processed: p == true ? true : null,
    hasError: p == false ? true : null,
  );
});

// ── Tài khoản ──
final adminAccountSearchProvider = StateProvider<String>((_) => '');
final adminUserRoleProvider = StateProvider<String?>((_) => null);
final adminUserSubProvider = StateProvider<String?>((_) => null);

final adminUsersProvider = FutureProvider.autoDispose<AdminUsers>((ref) {
  final s = ref.watch(adminAccountSearchProvider);
  final role = ref.watch(adminUserRoleProvider);
  final sub = ref.watch(adminUserSubProvider);
  return AdminApi.instance.users(
    search: s.isEmpty ? null : s,
    role: role,
    subscription: sub,
  );
});

final adminUserDetailProvider =
    FutureProvider.autoDispose.family<AdminUserDetail, int>((ref, id) {
      return AdminApi.instance.userDetail(id);
    });

/// Đơn thanh toán của 1 user (dùng cho nút "Xem đơn gần nhất" trong chi tiết TK).
final adminUserOrdersProvider =
    FutureProvider.autoDispose.family<AdminPaymentOrders, String>((ref, email) {
      return AdminApi.instance.billingOrders(search: email);
    });

// ── Nội dung (tab segmented: 0=Tài liệu, 1=Quiz/Flashcard, 2=Phiên live) ──
final adminContentSegProvider = StateProvider<int>((_) => 0);
final adminContentSearchProvider = StateProvider<String>((_) => '');
final adminContentDeletionProvider = StateProvider<String>((_) => 'Active');

final adminDocumentsProvider = FutureProvider.autoDispose<AdminDocuments>((ref) {
  final s = ref.watch(adminContentSearchProvider);
  final del = ref.watch(adminContentDeletionProvider);
  return AdminApi.instance.documents(
    search: s.isEmpty ? null : s,
    deletion: del,
  );
});

final adminQuizActivityProvider = StateProvider<String?>((_) => null);
final adminQuizStatusProvider = StateProvider<String?>((_) => null);

final adminQuizzesProvider = FutureProvider.autoDispose<AdminQuizzes>((ref) {
  final s = ref.watch(adminContentSearchProvider);
  final del = ref.watch(adminContentDeletionProvider);
  final act = ref.watch(adminQuizActivityProvider);
  final status = ref.watch(adminQuizStatusProvider);
  return AdminApi.instance.quizzes(
    search: s.isEmpty ? null : s,
    activityType: act,
    status: status,
    deletion: del,
  );
});

final adminSessStatusProvider = StateProvider<String?>((_) => null);

final adminSessionsProvider = FutureProvider.autoDispose<AdminSessions>((ref) {
  final s = ref.watch(adminContentSearchProvider);
  final del = ref.watch(adminContentDeletionProvider);
  final status = ref.watch(adminSessStatusProvider);
  return AdminApi.instance.sessions(
    search: s.isEmpty ? null : s,
    status: status,
    deletion: del,
  );
});

final adminParticipantsProvider =
    FutureProvider.autoDispose.family<AdminParticipants, int>((ref, sessionId) {
      return AdminApi.instance.sessionParticipants(sessionId);
    });
