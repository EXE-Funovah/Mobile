import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/models/quiz.dart';

void main() {
  group('QuizDto flashcard fields', () {
    test('parse activityType + questionCount (camelCase & PascalCase)', () {
      final camel = QuizDto.fromJson({
        'id': 1,
        'documentId': 2,
        'title': 'Bộ thẻ',
        'status': 'Teacher_Approved',
        'activityType': 'Flashcard',
        'questionCount': 6,
      });
      expect(camel.isFlashcard, isTrue);
      expect(camel.questionCount, 6);

      final pascal = QuizDto.fromJson({
        'Id': 1,
        'DocumentId': 2,
        'Title': 'Quiz',
        'Status': 'Teacher_Approved',
        'ActivityType': 'Quiz',
        'QuestionCount': 3,
      });
      expect(pascal.isFlashcard, isFalse);
      expect(pascal.questionCount, 3);
    });

    test('activityType mặc định là Quiz khi thiếu', () {
      final q = QuizDto.fromJson({'id': 1, 'title': 't', 'status': 's'});
      expect(q.activityType, 'Quiz');
      expect(q.isFlashcard, isFalse);
    });
  });

  group('QuizDetailDto', () {
    test('sắp câu hỏi theo position tăng dần', () {
      final detail = QuizDetailDto.fromJson({
        'id': 10,
        'documentId': 2,
        'title': 'Bộ thẻ',
        'activityType': 'Flashcard',
        'status': 'Teacher_Approved',
        'questions': [
          {
            'id': 3,
            'questionText': 'C',
            'questionType': 'Flashcard',
            'position': 2,
            'options': [
              {'id': 1, 'optionText': 'c', 'isCorrect': true},
            ],
          },
          {
            'id': 1,
            'questionText': 'A',
            'questionType': 'Flashcard',
            'position': 0,
            'options': [
              {'id': 2, 'optionText': 'a', 'isCorrect': true},
            ],
          },
          {
            'id': 2,
            'questionText': 'B',
            'questionType': 'Flashcard',
            'position': 1,
            'options': [
              {'id': 3, 'optionText': 'b', 'isCorrect': true},
            ],
          },
        ],
      });

      expect(detail.questions.map((q) => q.questionText).toList(), [
        'A',
        'B',
        'C',
      ]);
      // Mặt sau = option đúng đầu tiên (khớp cách study page lấy back).
      final back = detail.questions.first.options
          .firstWhere((o) => o.isCorrect)
          .optionText;
      expect(back, 'a');
    });
  });
}
