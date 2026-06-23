import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/quiz_attempt.dart';
import 'dio_client.dart';

class QuizAttemptApi {
  QuizAttemptApi._();
  static final QuizAttemptApi instance = QuizAttemptApi._();

  final Dio _dio = DioClient.instance.dio;

  /// POST /api/QuizAttempt — submit kết quả, nhận lại attempt + stats mới.
  Future<QuizAttemptDto> submit(QuizAttemptSubmitRequest request) async {
    final res = await _dio.post(
      ApiConstants.quizAttempts,
      data: request.toJson(),
    );
    _ensureOk(res);
    return QuizAttemptDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// GET /api/QuizAttempt/me?from=&to= — lịch sử attempt (week chart).
  Future<List<QuizAttemptDto>> getMine({DateTime? from, DateTime? to}) async {
    final res = await _dio.get(
      ApiConstants.quizAttemptsMe,
      queryParameters: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    _ensureOk(res);
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => QuizAttemptDto.fromJson(Map<String, dynamic>.from(e)))
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
