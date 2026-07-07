import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/quiz_api.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../models/flashcard.dart';

/// Lưu tiến độ "đã thuộc" của flashcard theo bộ (client-side, không có BE).
/// Flashcard KHÔNG chấm điểm/streak — chỉ ghi số thẻ đã thuộc để gợi ý ôn lại.
class FlashcardProgress {
  FlashcardProgress._();

  static String _key(int quizId) => 'fc_learned_$quizId';

  static Future<int> learnedOf(int quizId) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_key(quizId)) ?? 0;
  }

  /// Ghi số thẻ đã thuộc cao nhất đạt được cho bộ này.
  static Future<void> setLearned(int quizId, int learned) async {
    final sp = await SharedPreferences.getInstance();
    final current = sp.getInt(_key(quizId)) ?? 0;
    if (learned > current) await sp.setInt(_key(quizId), learned);
  }
}

/// Danh sách bộ flashcard của user + tiến độ học cục bộ.
final flashcardSetsProvider = FutureProvider<List<FlashcardSet>>((ref) async {
  final quizzes = await QuizApi.instance.getMine(activityType: 'Flashcard');
  quizzes.sort(
    (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
      a.createdAt ?? DateTime(1970),
    ),
  );
  final sets = <FlashcardSet>[];
  for (final q in quizzes) {
    final learned = await FlashcardProgress.learnedOf(q.id);
    sets.add(
      FlashcardSet(
        id: q.id,
        documentId: q.documentId,
        title: q.title,
        count: q.questionCount,
        learned: learned,
        isNew: learned == 0,
      ),
    );
  }
  return sets;
});

/// Thẻ để XEM TRƯỚC khi tạo flashcard từ 1 tài liệu — lấy bộ câu hỏi đã duyệt
/// của tài liệu (tái dùng `documentQuestionsProvider`), map front/back.
final flashcardCardsFromDocProvider =
    FutureProvider.family<List<FlashCard>, int>((ref, documentId) async {
      final questions = await ref.watch(
        documentQuestionsProvider(documentId).future,
      );
      return questions
          .map(
            (q) => FlashCard(
              front: q.q,
              back: q.correct >= 0 && q.correct < q.opts.length
                  ? q.opts[q.correct]
                  : (q.opts.isNotEmpty ? q.opts.first : ''),
            ),
          )
          .where((c) => c.front.trim().isNotEmpty && c.back.trim().isNotEmpty)
          .toList();
    });

/// Thẻ để HỌC — nạp chi tiết 1 bộ flashcard đã xuất bản, sort theo position.
final flashcardStudyProvider = FutureProvider.family<List<FlashCard>, int>((
  ref,
  quizId,
) async {
  final detail = await QuizApi.instance.getDetail(quizId);
  return detail.questions.map((q) {
    final back = q.options.isEmpty
        ? ''
        : (q.options.firstWhere(
            (o) => o.isCorrect,
            orElse: () => q.options.first,
          )).optionText;
    return FlashCard(front: q.questionText, back: back);
  }).toList();
});
