import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/models/quiz.dart';
import 'package:mascoteach_mobile/features/quiz/pages/quiz_preview_page.dart';

QuizPreviewArgs _args({int count = 2}) {
  return QuizPreviewArgs(
    documentId: 1,
    quizTitle: 'Trắc nghiệm: Demo',
    questions: List.generate(
      count,
      (i) => GeneratedQuestionDto(
        questionText: 'Câu hỏi số ${i + 1}?',
        questionType: 'MultipleChoice',
        options: const [
          GeneratedOptionDto(optionText: 'Đáp án đúng', isCorrect: true),
          GeneratedOptionDto(optionText: 'Đáp án sai', isCorrect: false),
        ],
      ),
    ),
  );
}

Widget _wrap(QuizPreviewArgs args) {
  return ProviderScope(
    child: MaterialApp(home: QuizPreviewPage(args: args)),
  );
}

void main() {
  testWidgets('hiển thị câu hỏi và nút Xuất bản, chưa tự lưu', (tester) async {
    await tester.pumpWidget(_wrap(_args()));

    expect(find.text('Câu hỏi số 1?'), findsOneWidget);
    expect(find.text('Câu hỏi số 2?'), findsOneWidget);
    expect(find.text('Xuất bản'), findsOneWidget);
    expect(find.textContaining('2 câu hỏi'), findsOneWidget);
    // Chưa publish thì chưa có màn thành công
    expect(find.text('Đã xuất bản!'), findsNothing);
  });

  testWidgets('xoá được câu hỏi nhưng giữ tối thiểu 1 câu', (tester) async {
    await tester.pumpWidget(_wrap(_args()));

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();

    expect(find.text('Câu hỏi số 1?'), findsNothing);
    expect(find.text('Câu hỏi số 2?'), findsOneWidget);
    // Còn 1 câu — nút xoá biến mất để không xoá rỗng bộ câu hỏi
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
