import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio dio = _build();

  Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
      // Không throw exception khi status >=400; mình tự xử lý
      validateStatus: (status) => status != null && status < 500,
    ));

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
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));

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
      options.headers['Authorization'] = 'Bearer $token';
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
    }
    handler.next(response);
  }
}
