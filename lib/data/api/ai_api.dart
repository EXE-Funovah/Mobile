import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/quiz.dart';

class AiApi {
  AiApi._();
  static AiApi instance = AiApi._();

  Future<List<GeneratedQuestionDto>> generateQuestions({
    required String fileUrl,
    required int documentId,
    required String quizTitle,
    required int numberOfQuestions,
    required String difficulty,
  }) async {
    Map<int, int> distribution;
    if (difficulty == 'Dễ') {
      distribution = {1: 50, 2: 30, 3: 20};
    } else if (difficulty == 'Khó') {
      distribution = {1: 20, 2: 40, 3: 40};
    } else {
      distribution = {1: 40, 2: 40, 3: 20};
    }

    final raw = Dio(
      BaseOptions(
        baseUrl: ApiConstants.aiBaseUrl,
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    final res = await raw.post(
      '/api/v1/ai/generate-for-backend',
      data: {
        'fileUrl': fileUrl,
        'documentId': documentId,
        'quizTitle': quizTitle,
        'numberOfQuestions': numberOfQuestions,
        'difficultyDistribution': distribution,
        'language': 'vi',
      },
    );

    if (res.statusCode == null || res.statusCode! >= 300) {
      throw Exception('AI Generation failed: ${res.statusCode}');
    }

    final data = res.data;
    if (data is Map) {
      final success = data['success'] == true;
      if (!success) {
        throw Exception(data['message'] ?? 'AI Module trả về lỗi');
      }
      final questionsList = data['data']?['questions'];
      if (questionsList is List) {
        return questionsList
            .map(
              (q) => GeneratedQuestionDto.fromJson(
                Map<String, dynamic>.from(q as Map),
              ),
            )
            .toList();
      }
    }
    throw Exception('Phản hồi từ AI không đúng định dạng');
  }
}
