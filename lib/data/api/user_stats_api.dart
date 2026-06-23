import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_stats.dart';
import 'dio_client.dart';

class UserStatsApi {
  UserStatsApi._();
  static final UserStatsApi instance = UserStatsApi._();

  final Dio _dio = DioClient.instance.dio;

  /// GET /api/UserStats/me — stats của user hiện tại (BE tự tạo nếu chưa có).
  /// (BE không expose /{userId} — tránh lộ stats user khác.)
  Future<UserStatsDto> getMine() async {
    final res = await _dio.get(ApiConstants.userStatsMe);
    _ensureOk(res);
    return UserStatsDto.fromJson(Map<String, dynamic>.from(res.data as Map));
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
