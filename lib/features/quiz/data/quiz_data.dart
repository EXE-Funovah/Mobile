/// Model UI dùng để render câu hỏi trên màn `QuizPlayPage`.
///
/// Dữ liệu thực được nạp qua `quizQuestionsProvider` / `documentQuestionsProvider`
/// trong `providers/quizzes_provider.dart` rồi map sang `QuizQ`.
class QuizQ {
  final String q;
  final List<String> opts;
  final int correct;
  final int lv;
  const QuizQ({
    required this.q,
    required this.opts,
    required this.correct,
    required this.lv,
  });
}
