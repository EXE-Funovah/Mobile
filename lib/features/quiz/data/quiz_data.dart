/// Model UI dùng để render câu hỏi trên màn `QuizPlayPage`.
///
/// Dữ liệu thực được nạp qua `quizQuestionsProvider` / `documentQuestionsProvider`
/// trong `providers/quizzes_provider.dart` rồi map sang `QuizQ`.
/// `questionId` + `optionIds` cần cho submit server-side scoring
/// (`POST /api/QuizAttempt` nhận answers[{questionId, optionId}]).
class QuizQ {
  final String q;
  final List<String> opts;
  final int correct;
  final int lv;
  final int questionId;
  final List<int> optionIds; // song song với opts
  const QuizQ({
    required this.q,
    required this.opts,
    required this.correct,
    required this.lv,
    this.questionId = 0,
    this.optionIds = const [],
  });
}
