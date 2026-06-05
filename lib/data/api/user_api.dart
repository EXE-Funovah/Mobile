import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

/// User profile lấy từ `GET /api/User/me`.
class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String subscriptionTier;
  final int documentsProcessed;
  final DateTime? createdAt;
  final String? authenticator; // 'Google' / 'Local' / 'Both'

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.subscriptionTier,
    this.documentsProcessed = 0,
    this.createdAt,
    this.authenticator,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: _int(json['id'] ?? json['Id']) ?? 0,
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      role: (json['role'] ?? json['Role'] ?? '').toString(),
      subscriptionTier:
          (json['subscriptionTier'] ?? json['SubscriptionTier'] ?? 'Freemium')
              .toString(),
      documentsProcessed:
          _int(json['documentsProcessed'] ?? json['DocumentsProcessed']) ?? 0,
      createdAt: _date(json['createdAt'] ?? json['CreatedAt']),
      authenticator: (json['authenticator'] ?? json['Authenticator'])
          ?.toString(),
    );
  }

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _date(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}

class UserApi {
  UserApi._();
  static final UserApi instance = UserApi._();

  final Dio _dio = DioClient.instance.dio;

  Future<UserProfile> getMe() async {
    final res = await _dio.get(ApiConstants.userMe);
    _ensureOk(res);
    return UserProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// PUT /api/User/{id} — chỉ owner hoặc admin sửa được.
  Future<void> update({
    required int id,
    required String fullName,
    required String email,
    required String role,
    required String subscriptionTier,
  }) async {
    final res = await _dio.put(
      '${ApiConstants.users}/$id',
      data: {
        'fullName': fullName,
        'email': email,
        'role': role,
        'subscriptionTier': subscriptionTier,
      },
    );
    _ensureOk(res);
  }

  /// DELETE /api/User/{id} — soft delete tài khoản của chính mình.
  Future<void> delete(int id) async {
    final res = await _dio.delete('${ApiConstants.users}/$id');
    _ensureOk(res);
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
