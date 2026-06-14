import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/ai_api.dart';

void main() {
  group('AiApi.difficultyDistributionFor', () {
    test('payload generate-for-backend luôn jsonEncode được', () {
      for (final difficulty in ['Dễ', 'Vừa', 'Khó', 'unknown']) {
        final body = {
          'fileUrl': 'https://example.com/file.zip',
          'documentId': 1,
          'quizTitle': 'Trắc nghiệm',
          'numberOfQuestions': 5,
          'difficultyDistribution': AiApi.difficultyDistributionFor(difficulty),
          'language': 'vi',
        };
        // Regression: key int trong distribution từng làm jsonEncode throw
        // "Converting object to an encodable object failed: _Map len:3".
        expect(() => jsonEncode(body), returnsNormally);
      }
    });

    test('tổng phân bố mỗi mức độ là 100%', () {
      for (final difficulty in ['Dễ', 'Vừa', 'Khó']) {
        final d = AiApi.difficultyDistributionFor(difficulty);
        expect(d.keys, unorderedEquals(['1', '2', '3']));
        expect(d.values.reduce((a, b) => a + b), 100);
      }
    });
  });
}
