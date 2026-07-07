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

  /// GET /api/Quiz/me?activityType=Quiz|Flashcard
  ///
  /// Trả bộ của user hiện tại (kèm `questionCount`, `activityType`).
  /// `activityType == null` → lấy tất cả.
  Future<List<QuizDto>> getMine({String? activityType}) async {
    final qp = <String, dynamic>{};
    if (activityType != null) qp['activityType'] = activityType;
    final res = await _dio.get(
      '${ApiConstants.quizzes}/me',
      queryParameters: qp,
    );
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

  /// GET /api/Quiz/{id}/detail — chi tiết bộ, câu hỏi sort theo `position`.
  Future<QuizDetailDto> getDetail(int id) async {
    final res = await _dio.get('${ApiConstants.quizzes}/$id/detail');
    _ensureOk(res);
    return QuizDetailDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// POST /api/Quiz/publish — xuất bản CẢ bộ trong 1 transaction.
  ///
  /// [questions] mỗi phần tử: `{questionText, questionType, position, options}`
  /// với `options` = list `{optionText, isCorrect}`. Với Flashcard: mỗi câu
  /// đúng 1 option (mặt sau, isCorrect=true), questionType = "Flashcard".
  Future<QuizDetailDto> publish({
    required int documentId,
    required String title,
    required String activityType,
    required List<Map<String, dynamic>> questions,
  }) async {
    final res = await _dio.post(
      '${ApiConstants.quizzes}/publish',
      data: {
        'documentId': documentId,
        'title': title,
        'activityType': activityType,
        'questions': questions,
      },
    );
    _ensureOk(res);
    return QuizDetailDto.fromJson(Map<String, dynamic>.from(res.data as Map));
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
