import 'package:dio/dio.dart';
import '../../../data/api/dio_client.dart';
import 'admin_models.dart';

/// Gọi `/api/Admin/*` (yêu cầu role Admin — DioClient tự gắn JWT).
class AdminApi {
  AdminApi._();
  static final AdminApi instance = AdminApi._();

  final Dio _dio = DioClient.instance.dio;

  /// GET /api/Admin/overview?range=7d|30d|12m
  Future<AdminOverview> overview({String range = '30d'}) async {
    final res = await _dio.get(
      '/api/Admin/overview',
      queryParameters: {'range': range},
    );
    _ok(res);
    return AdminOverview.fromJson(res.data as Map);
  }

  /// GET /api/Admin/users — danh sách tài khoản (phân trang + filter).
  Future<AdminUsers> users({
    String? search,
    String? role,
    String? subscription,
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (role != null && role.isNotEmpty) qp['role'] = role;
    if (subscription != null && subscription.isNotEmpty) {
      qp['subscription'] = subscription;
    }
    final res = await _dio.get('/api/Admin/users', queryParameters: qp);
    _ok(res);
    return AdminUsers.fromJson(res.data as Map);
  }

  /// GET /api/Admin/users/{id} — chi tiết tài khoản (số liệu học tập + thanh toán).
  Future<AdminUserDetail> userDetail(int id) async {
    final res = await _dio.get('/api/Admin/users/$id');
    _ok(res);
    return AdminUserDetail.fromJson(res.data as Map);
  }

  /// GET /api/Admin/documents — danh sách tài liệu (mọi user).
  Future<AdminDocuments> documents({
    String? search,
    String deletion = 'Active',
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{
      'deletion': deletion,
      'page': page,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) qp['search'] = search;
    final res = await _dio.get('/api/Admin/documents', queryParameters: qp);
    _ok(res);
    return AdminDocuments.fromJson(res.data as Map);
  }

  /// GET /api/Admin/quizzes — danh sách quiz/flashcard.
  Future<AdminQuizzes> quizzes({
    String? search,
    String? activityType,
    String? status,
    String deletion = 'Active',
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{
      'deletion': deletion,
      'page': page,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (activityType != null && activityType.isNotEmpty) {
      qp['activityType'] = activityType;
    }
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final res = await _dio.get('/api/Admin/quizzes', queryParameters: qp);
    _ok(res);
    return AdminQuizzes.fromJson(res.data as Map);
  }

  /// GET /api/Admin/sessions — danh sách phiên live.
  Future<AdminSessions> sessions({
    String? search,
    String? status,
    String deletion = 'Active',
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{
      'deletion': deletion,
      'page': page,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final res = await _dio.get('/api/Admin/sessions', queryParameters: qp);
    _ok(res);
    return AdminSessions.fromJson(res.data as Map);
  }

  /// GET /api/Admin/sessions/{id}/participants — bảng xếp hạng người tham gia.
  Future<AdminParticipants> sessionParticipants(
    int sessionId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final res = await _dio.get(
      '/api/Admin/sessions/$sessionId/participants',
      queryParameters: {'deletion': 'All', 'page': page, 'pageSize': pageSize},
    );
    _ok(res);
    return AdminParticipants.fromJson(res.data as Map);
  }

  /// GET /api/Admin/billing/webhook-events — sự kiện webhook PayOS.
  Future<AdminWebhookEvents> webhookEvents({
    String? search,
    bool? processed,
    bool? hasError,
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (processed != null) qp['processed'] = processed;
    if (hasError != null) qp['hasError'] = hasError;
    final res = await _dio.get(
      '/api/Admin/billing/webhook-events',
      queryParameters: qp,
    );
    _ok(res);
    return AdminWebhookEvents.fromJson(res.data as Map);
  }

  /// GET /api/Admin/billing/orders — danh sách đơn thanh toán (PayOS).
  Future<AdminPaymentOrders> billingOrders({
    String? search,
    String? status,
    String? plan,
    int page = 1,
    int pageSize = 30,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (plan != null && plan.isNotEmpty) qp['plan'] = plan;
    final res = await _dio.get('/api/Admin/billing/orders', queryParameters: qp);
    _ok(res);
    return AdminPaymentOrders.fromJson(res.data as Map);
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
