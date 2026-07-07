import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/network_error_formatter.dart';
import '../models/mascot_live_session.dart';
import '../storage/token_storage.dart';

class MascotLiveApi {
  MascotLiveApi._({Future<String?> Function()? tokenReader})
    : _tokenReader = tokenReader ?? TokenStorage.instance.getToken;
  static final MascotLiveApi instance = MascotLiveApi._();
  final Future<String?> Function() _tokenReader;

  @visibleForTesting
  factory MascotLiveApi.forTesting({
    required Future<String?> Function() tokenReader,
  }) => MascotLiveApi._(tokenReader: tokenReader);

  @visibleForTesting
  Future<Map<String, String>> authJsonHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = (await _tokenReader())?.trim();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Dio> _client() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.aiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: await authJsonHeaders(),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (!kIsWeb && kDebugMode) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    return dio;
  }

  Future<MascotLiveSession> createSession({
    String displayName = 'Mascoteach learner',
    String language = 'vi',
    String? voice,
  }) async {
    try {
      final res = await (await _client()).post(
        ApiConstants.mascotLiveSession,
        data: {
          'displayName': displayName,
          'language': language,
          if (voice != null && voice.trim().isNotEmpty) 'voice': voice.trim(),
        },
      );

      return _parseSessionResponse(
        res,
        defaultError: 'Không tạo được phiên thoại của Sumadi',
      );
    } on DioException catch (error) {
      throw Exception(
        formatNetworkError(
          error,
          fallbackMessage: 'Không tạo được phiên thoại của Sumadi',
        ),
      );
    }
  }

  Future<MascotLiveSession> getSession(String sessionId) async {
    try {
      final res = await (await _client()).get(
        ApiConstants.mascotLiveSessionById(sessionId),
      );
      return _parseSessionResponse(
        res,
        defaultError: 'Không lấy được trạng thái phiên thoại',
      );
    } on DioException catch (error) {
      throw Exception(
        formatNetworkError(
          error,
          fallbackMessage: 'Không lấy được trạng thái phiên thoại',
        ),
      );
    }
  }

  Future<MascotLiveSession> endSession(String sessionId) async {
    try {
      final res = await (await _client()).post(
        ApiConstants.mascotLiveEndSession(sessionId),
      );
      return _parseSessionResponse(
        res,
        defaultError: 'Không đóng được phiên thoại',
      );
    } on DioException catch (error) {
      throw Exception(
        formatNetworkError(
          error,
          fallbackMessage: 'Không đóng được phiên thoại',
        ),
      );
    }
  }

  Future<String> exchangeRealtimeSdp({
    required MascotLiveSession session,
    required String offerSdp,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: session.connection.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.plain,
          headers: {
            'Authorization': 'Bearer ${session.clientSecret.value}',
            'Content-Type': 'application/sdp',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final res = await dio.post(
        session.connection.callEndpoint,
        data: offerSdp,
      );

      if (res.statusCode == null || res.statusCode! >= 300) {
        throw Exception(
          _extractMessage(res.data) ??
              'Không tạo được kết nối với Sumadi (${res.statusCode})',
        );
      }

      final data = res.data;
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      throw Exception('Kết nối trả về dữ liệu không hợp lệ');
    } on DioException catch (error) {
      throw Exception(
        formatNetworkError(
          error,
          fallbackMessage: 'Không tạo được kết nối với Sumadi',
        ),
      );
    }
  }

  Future<String> sendChatMessage(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    try {
      final res = await (await _client()).post(
        ApiConstants.aiChat,
        data: {'message': message, 'history': history},
      );

      final data = res.data;
      if (res.statusCode == null || res.statusCode! >= 300) {
        throw Exception(
          _extractMessage(data) ?? 'AI chat lỗi (${res.statusCode})',
        );
      }

      if (data is Map) {
        final success = data['success'] == true;
        if (!success) {
          throw Exception(_extractMessage(data) ?? 'AI chat trả về lỗi');
        }

        final reply =
            data['reply'] ??
            (data['data'] is Map ? (data['data'] as Map)['reply'] : null);
        final text = reply?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }

      throw Exception('AI chat trả về dữ liệu không hợp lệ');
    } on DioException catch (error) {
      throw Exception(
        formatNetworkError(error, fallbackMessage: 'Không gửi được prompt'),
      );
    }
  }

  MascotLiveSession _parseSessionResponse(
    Response<dynamic> res, {
    required String defaultError,
  }) {
    final data = res.data;
    if (res.statusCode == null || res.statusCode! >= 300) {
      throw Exception(
        _extractMessage(data) ?? '$defaultError (${res.statusCode})',
      );
    }

    if (data is Map) {
      final success = data['success'] == true;
      if (!success) {
        throw Exception(_extractMessage(data) ?? defaultError);
      }

      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        return MascotLiveSession.fromJson(payload);
      }
      if (payload is Map) {
        return MascotLiveSession.fromJson(
          payload.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }

    throw Exception('$defaultError: phản hồi không đúng định dạng');
  }

  String? _extractMessage(Object? payload) {
    if (payload is Map) {
      final message = payload['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    return null;
  }
}
