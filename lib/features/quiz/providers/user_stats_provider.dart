import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/quiz_attempt_api.dart';
import '../../../data/api/user_stats_api.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../../data/models/user_stats.dart';

/// Stats gamification của user hiện tại. Invalidate sau khi submit attempt.
final userStatsProvider = FutureProvider<UserStatsDto>((ref) async {
  return UserStatsApi.instance.getMine();
});

/// Submit kết quả quiz rồi refresh stats.
/// Dùng: `await ref.read(submitQuizAttemptProvider)(request);`
final submitQuizAttemptProvider =
    Provider<Future<QuizAttemptDto> Function(QuizAttemptSubmitRequest)>((ref) {
  return (request) async {
    final result = await QuizAttemptApi.instance.submit(request);
    ref.invalidate(userStatsProvider);
    ref.invalidate(weekAttemptsProvider);
    return result;
  };
});

/// Lịch sử attempt 7 ngày gần nhất (cho week chart sau này).
final weekAttemptsProvider = FutureProvider<List<QuizAttemptDto>>((ref) async {
  final now = DateTime.now();
  return QuizAttemptApi.instance.getMine(
    from: now.subtract(const Duration(days: 7)),
    to: now,
  );
});
