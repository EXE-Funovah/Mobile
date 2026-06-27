import 'package:dio/dio.dart';
import '../../../data/api/dio_client.dart';
import 'admin_models.dart';

/// Gọi `/api/Admin/*` (yêu cầu role Admin — DioClient tự gắn JWT).
class AdminApi {
  AdminApi._();
  static final AdminApi instance = AdminApi._();

  final Dio _dio = DioClient.instance.dio;

  Future<AdminOverview> overview({String range = '30d'}) async {
    final res = await _dio.get(
      '/api/Admin/overview',
      queryParameters: {'range': range},
    );
    _ok(res);
    return AdminOverview.fromJson(res.data as Map);
  }

  Future<AdminRevenue> revenue({String range = '30d'}) async {
    final res = await _dio.get(
      '/api/Admin/revenue',
      queryParameters: {'range': range},
    );
    _ok(res);
    return AdminRevenue.fromJson(res.data as Map);
  }

  Future<AdminAccounts> accounts({
    String? search,
    String? tier,
    int page = 1,
    int pageSize = 30,
  }) async {
    final res = await _dio.get(
      '/api/Admin/accounts',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (tier != null && tier.isNotEmpty) 'tier': tier,
        'page': page,
        'pageSize': pageSize,
      },
    );
    _ok(res);
    return AdminAccounts.fromJson(res.data as Map);
  }

  void _ok(Response res) {
    final c = res.statusCode ?? 0;
    if (c < 200 || c >= 300) {
      throw Exception(
        (c == 401 || c == 403)
            ? 'Bạn không có quyền truy cập admin.'
            : 'Lỗi tải dữ liệu admin ($c).',
      );
    }
  }
}
