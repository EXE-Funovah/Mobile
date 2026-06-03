import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/quiz_api.dart';
import '../../../data/api/question_api.dart';
import '../../../data/models/quiz.dart';
import '../data/quiz_data.dart';

import 'documents_provider.dart';

class QuizzesState {
  final bool loading;
  final List<QuizDto> items;
  final String? error;

  const QuizzesState({this.loading = false, this.items = const [], this.error});

  QuizzesState copyWith({
    bool? loading,
    List<QuizDto>? items,
    String? error,
    bool clearError = false,
  }) => QuizzesState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    error: clearError ? null : (error ?? this.error),
  );
}

class QuizzesController extends StateNotifier<QuizzesState> {
  final Ref _ref;
  QuizzesController(this._ref) : super(const QuizzesState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final docState = _ref.read(documentsProvider);
      final docs = docState.items;

      final List<QuizDto> allQuizzes = [];
      for (final doc in docs) {
        try {
          final quizzes = await QuizApi.instance.getQuizzesByDocument(doc.id);
          allQuizzes.addAll(quizzes);
        } catch (_) {
          // Bỏ qua lỗi lẻ của từng doc
        }
      }

      // Sắp xếp mới nhất trước
      allQuizzes.sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
      state = QuizzesState(items: allQuizzes);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final quizzesProvider = StateNotifierProvider<QuizzesController, QuizzesState>((
  ref,
) {
  final controller = QuizzesController(ref);

  ref.listen(documentsProvider, (prev, next) {
    if (prev?.items != next.items) {
      controller.refresh();
    }
  });

  return controller;
});

/// Helper function to map dynamic API QuestionDto models to the local QuizQ UI model.
List<QuizQ> mapDtoToQuizQs(List<QuestionDto> dtos) {
  final List<QuizQ> list = [];
  for (final q in dtos) {
    final opts = q.options.map((o) => o.optionText).toList();
    final correctIndex = q.options.indexWhere((o) => o.isCorrect);
    final correct = correctIndex != -1 ? correctIndex : 0;
    list.add(
      QuizQ(
        q: q.questionText,
        opts: opts,
        correct: correct,
        lv: 1, // Default to level 1 for display
      ),
    );
  }
  return list;
}

/// Fetch and map questions by quizId
final quizQuestionsProvider = FutureProvider.family<List<QuizQ>, int>((
  ref,
  quizId,
) async {
  final questions = await QuestionApi.instance.getQuestionsByQuiz(quizId);
  return mapDtoToQuizQs(questions);
});

/// Fetch and map questions from the first quiz of a documentId
final documentQuestionsProvider = FutureProvider.family<List<QuizQ>, int>((
  ref,
  documentId,
) async {
  final quizzes = await QuizApi.instance.getQuizzesByDocument(documentId);
  if (quizzes.isEmpty) {
    throw Exception('Tài liệu này chưa được tạo bộ câu hỏi nào.');
  }
  final quizId = quizzes.first.id;
  final questions = await QuestionApi.instance.getQuestionsByQuiz(quizId);
  return mapDtoToQuizQs(questions);
});
