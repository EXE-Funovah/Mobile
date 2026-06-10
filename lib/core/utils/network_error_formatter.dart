import 'package:dio/dio.dart';

String formatNetworkError(
  Object error, {
  required String fallbackMessage,
}) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final serverMessage = _extractPayloadMessage(error.response?.data);

    switch (statusCode) {
      case 400:
        return serverMessage ?? '$fallbackMessage (400)';
      case 401:
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn chưa có quyền thực hiện thao tác này.';
      case 404:
        return serverMessage ?? 'Không tìm thấy dữ liệu cần thiết (404).';
      case 429:
        return 'Hệ thống đang bận. Vui lòng thử lại sau ít phút.';
      case 500:
        return 'Máy chủ Sumadi đang gặp lỗi (500). Vui lòng thử lại sau.';
      case 502:
        return 'Máy chủ Sumadi đang tạm lỗi (502). Vui lòng thử lại sau ít phút.';
      case 503:
        return 'Dịch vụ Sumadi đang tạm bảo trì (503). Vui lòng thử lại sau.';
      case 504:
        return 'Máy chủ phản hồi quá lâu (504). Vui lòng thử lại sau.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối tới máy chủ bị quá thời gian. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới máy chủ. Hãy kiểm tra mạng và thử lại.';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.badCertificate:
        return 'Kết nối bảo mật tới máy chủ không hợp lệ.';
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        break;
    }

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }
  }

  final cleaned = error.toString().replaceFirst('Exception: ', '').trim();
  if (cleaned.isEmpty || cleaned == 'null') {
    return fallbackMessage;
  }
  if (cleaned.startsWith('DioException')) {
    return fallbackMessage;
  }
  return cleaned;
}

String? _extractPayloadMessage(Object? payload) {
  if (payload is Map) {
    final directMessage = payload['message']?.toString().trim();
    if (directMessage != null && directMessage.isNotEmpty) return directMessage;

    final errorMessage = payload['error']?.toString().trim();
    if (errorMessage != null && errorMessage.isNotEmpty) return errorMessage;

    final nested = payload['data'];
    if (nested is Map) {
      final nestedMessage = nested['message']?.toString().trim();
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }
  }

  if (payload is String) {
    final text = payload.trim();
    if (text.isNotEmpty && !text.startsWith('<!DOCTYPE html')) {
      return text;
    }
  }

  return null;
}
