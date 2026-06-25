import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

/// Gọi backend tạo link thanh toán PayOS.
/// Backend giữ toàn bộ key PayOS; mobile chỉ nhận về `checkoutUrl` rồi mở.
class BillingApi {
  BillingApi._();
  static final BillingApi instance = BillingApi._();

  final Dio _dio = DioClient.instance.dio;

  /// POST /api/Billing/create-payment-link
  /// [planCode] = 'PRO_MONTHLY' | 'PRO_YEARLY'.
  /// Trả về `checkoutUrl` của PayOS để mở bằng trình duyệt ngoài.
  Future<String> createPaymentLink(String planCode) async {
    try {
      final res = await _dio.post(
        ApiConstants.billingCreatePaymentLink,
        data: {'planCode': planCode},
      );
      final data = res.data;
      final status = res.statusCode ?? 0;

      if (status >= 200 && status < 300 && data is Map) {
        final url = (data['checkoutUrl'] ?? data['CheckoutUrl'])?.toString();
        if (url != null && url.isNotEmpty) return url;
        throw Exception('Phản hồi thanh toán không có đường dẫn.');
      }
      throw Exception(_extractError(data, status));
    } on DioException catch (e) {
      throw Exception(
        _extractError(e.response?.data, e.response?.statusCode ?? 0),
      );
    }
  }

  String _extractError(dynamic data, int status) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return 'Không tạo được link thanh toán ($status).';
  }
}
