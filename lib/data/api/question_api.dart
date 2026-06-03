import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/quiz.dart';
import 'dio_client.dart';

class QuestionApi {
  QuestionApi._();
  static QuestionApi instance = QuestionApi._();

  final Dio _dio = DioClient.instance.dio;

  /// POST /api/Question
  Future<QuestionDto> createQuestion({
    required int quizId,
    required String questionText,
    required String questionType,
    required List<Map<String, dynamic>> options,
  }) async {
    final res = await _dio.post(
      ApiConstants.questions,
      data: {
        'quizId': quizId,
        'questionText': questionText,
        'questionType': questionType,
        'options': options,
      },
    );
    _ensureOk(res);
    return QuestionDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// GET /api/Question/quiz/{quizId}
  Future<List<QuestionDto>> getQuestionsByQuiz(int quizId) async {
    final res = await _dio.get('${ApiConstants.questions}/quiz/$quizId');
    _ensureOk(res);
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => QuestionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  void _ensureOk(Response res) {
    if (res.statusCode == null || res.statusCode! >= 400) {
      final d = res.data;
      String msg = 'Lỗi ${res.statusCode}';
      if (d is Map) {
        msg = (d['message'] ?? d['Message'] ?? d['error'] ?? msg).toString();
      } else if (d is String && d.isNotEmpty) {
        msg = d;
      }
      throw Exception(msg);
    }
  }
}
