import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/jwt_utils.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  /// Gọi khi token hết hạn/bị từ chối (401) — authProvider đăng ký để
  /// force logout + router đá về /login (giống web: clearAuth → /signin).
  static void Function()? onSessionExpired;

  late final Dio dio = _build();

  Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
        // Không throw exception khi status >=400; mình tự xử lý
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Trên dev, chấp nhận cert tự ký của .NET (https://localhost:7108)
    // CHỈ dùng trong debug, KHÔNG dùng cho release.
    if (!kIsWeb && kDebugMode) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.instance.getToken();
    if (token != null && token.isNotEmpty) {
      // Token hợp lệ không bao giờ chứa khoảng trắng/HTML. Nếu lỡ lưu nhầm
      // (vd. trang 301 của server) → tự xoá để user login lại, tránh
      // FormatInvalid khi set header.
      if (token.contains(RegExp(r'[\s<>]'))) {
        await TokenStorage.instance.clear();
      } else if (isJwtExpired(token)) {
        // JWT backend chỉ sống 60' và không có refresh — gửi đi kiểu gì
        // cũng 401, nên cắt phiên ngay tại đây cho user login lại.
        await TokenStorage.instance.clear();
        DioClient.onSessionExpired?.call();
      } else {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.statusCode == 401) {
      await TokenStorage.instance.clear();
      DioClient.onSessionExpired?.call();
    }
    handler.next(response);
  }
}
