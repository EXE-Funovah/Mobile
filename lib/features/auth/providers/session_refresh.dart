import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../flashcard/providers/flashcard_providers.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../quiz/providers/user_stats_provider.dart';
import '../../student/providers/nav_providers.dart';
import '../../student/providers/payment_history_provider.dart';
import 'auth_provider.dart';
import 'user_profile_provider.dart';

/// Reset mọi provider gắn với user hiện tại.
///
/// PHẢI gọi sau khi login/logout: các StateNotifierProvider global
/// (documents, quizzes, stats…) chạy fetch 1 lần lúc tạo. Nếu lần tạo đó
/// rơi vào lúc chưa có token (hoặc token user cũ), chúng giữ state rỗng/sai
/// và không tự fetch lại → invalidate để lần đọc kế tạo mới với token đúng.
void resetUserScopedProviders(WidgetRef ref) {
  ref.invalidate(documentsProvider);
  ref.invalidate(quizzesProvider);
  ref.invalidate(flashcardSetsProvider);
  ref.invalidate(userStatsProvider);
  ref.invalidate(weekAttemptsProvider);
  ref.invalidate(userProfileProvider);
  ref.invalidate(paymentHistoryProvider);
  ref.invalidate(libraryTabProvider);
  ref.invalidate(studentTabRequestProvider);
}

Future<void> logoutAndReset(WidgetRef ref) async {
  await ref.read(authProvider.notifier).logout();
  resetUserScopedProviders(ref);
}
