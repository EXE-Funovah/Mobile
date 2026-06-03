import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/quiz.dart';
import 'dio_client.dart';

class QuizApi {
  QuizApi._();
  static QuizApi instance = QuizApi._();

  final Dio _dio = DioClient.instance.dio;

  /// POST /api/Quiz
  Future<QuizDto> createQuiz({
    required int documentId,
    required String title,
  }) async {
    final res = await _dio.post(
      ApiConstants.quizzes,
      data: {'documentId': documentId, 'title': title},
    );
    _ensureOk(res);
    return QuizDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// PUT /api/Quiz/{id}
  Future<void> updateQuiz(
    int id, {
    required String title,
    required String status,
  }) async {
    final res = await _dio.put(
      '${ApiConstants.quizzes}/$id',
      data: {'title': title, 'status': status},
    );
    _ensureOk(res);
  }

  /// GET /api/Quiz
  Future<List<QuizDto>> getAllQuizzes() async {
    final res = await _dio.get(ApiConstants.quizzes);
    _ensureOk(res);
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => QuizDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  /// GET /api/Quiz/document/{documentId}
  Future<List<QuizDto>> getQuizzesByDocument(int documentId) async {
    final res = await _dio.get('${ApiConstants.quizzes}/document/$documentId');
    _ensureOk(res);
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => QuizDto.fromJson(Map<String, dynamic>.from(e)))
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
