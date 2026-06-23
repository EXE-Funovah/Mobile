import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

class AuthResult {
  final String token;
  final String? role;
  final String? fullName;
  AuthResult({required this.token, this.role, this.fullName});
}

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  final Dio _dio = DioClient.instance.dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      ApiConstants.authLogin,
      data: {'email': email, 'password': password},
    );

    if (res.statusCode != null && res.statusCode! >= 300) {
      throw _extractError(res);
    }

    final data = res.data;
    final token = _extractToken(data);
    if (token == null || token.isEmpty) {
      throw Exception('Phản hồi không có token');
    }
    return AuthResult(
      token: token,
      role: _extractField(data, ['role', 'Role']),
      fullName: _extractField(data, ['fullName', 'FullName', 'name']),
    );
  }

  /// Đăng nhập bằng Google idToken (đã lấy qua google_sign_in trên client).
  Future<AuthResult> googleLogin({required String idToken}) async {
    final res = await _dio.post(
      ApiConstants.authGoogleLogin,
      data: {'credential': idToken},
    );

    if (res.statusCode != null && res.statusCode! >= 300) {
      throw _extractError(res);
    }

    final data = res.data;
    final token = _extractToken(data);
    if (token == null || token.isEmpty) {
      throw Exception('Phản hồi không có token');
    }
    return AuthResult(
      token: token,
      role: _extractField(data, ['role', 'Role']),
      fullName: _extractField(data, ['fullName', 'FullName', 'name']),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role, // 'Student' | 'Teacher' | 'Parent'
  }) async {
    final res = await _dio.post(
      ApiConstants.authRegister,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      },
    );
    if (res.statusCode != null && res.statusCode! >= 300) {
      throw _extractError(res);
    }
  }

  /// Gửi mã reset password tới email user.
  Future<void> forgotPassword({required String email}) async {
    final res = await _dio.post(
      ApiConstants.authForgotPassword,
      data: {'email': email},
    );
    if (res.statusCode != null && res.statusCode! >= 300) {
      throw _extractError(res);
    }
  }

  /// JWT có dạng `xxx.yyy.zzz` (base64url) — không khoảng trắng, không HTML.
  /// Chặn case server trả trang HTML (301 redirect…) bị lưu nhầm làm token.
  static bool _looksLikeJwt(String s) =>
      RegExp(r'^[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+$')
          .hasMatch(s.trim());

  String? _extractToken(dynamic data) {
    if (data is String) {
      return _looksLikeJwt(data) ? data.trim() : null;
    }
    if (data is Map) {
      for (final key in ['token', 'accessToken', 'Token', 'AccessToken']) {
        final v = data[key];
        if (v is String && _looksLikeJwt(v)) return v.trim();
      }
      // có khi token bọc trong { data: { token: ... } }
      if (data['data'] is Map) return _extractToken(data['data']);
    }
    return null;
  }

  String? _extractField(dynamic data, List<String> keys) {
    if (data is Map) {
      for (final k in keys) {
        final v = data[k];
        if (v is String && v.isNotEmpty) return v;
      }
      if (data['data'] is Map) return _extractField(data['data'], keys);
    }
    return null;
  }

  Exception _extractError(Response res) {
    final d = res.data;
    String msg = 'Lỗi ${res.statusCode}';
    if (d is Map) {
      msg =
          d['message']?.toString() ??
          d['Message']?.toString() ??
          d['error']?.toString() ??
          msg;
    } else if (d is String && d.isNotEmpty) {
      msg = d;
    }
    return Exception(msg);
  }
}
