import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../quiz/providers/user_stats_provider.dart';
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
  ref.invalidate(userStatsProvider);
  ref.invalidate(weekAttemptsProvider);
  ref.invalidate(userProfileProvider);
}
