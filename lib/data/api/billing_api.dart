import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

class PaymentOrder {
  final int id;
  final int orderCode;
  final String planCode;
  final int amount;
  final String currency;
  final String status;
  final String provider;
  final String? checkoutUrl;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentOrder({
    required this.id,
    required this.orderCode,
    required this.planCode,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.createdAt,
    this.checkoutUrl,
    this.paidAt,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => PaymentOrder(
    id: _intOf(json['id'] ?? json['Id']),
    orderCode: _intOf(json['orderCode'] ?? json['OrderCode']),
    planCode: '${json['planCode'] ?? json['PlanCode'] ?? ''}',
    amount: _intOf(json['amount'] ?? json['Amount']),
    currency: '${json['currency'] ?? json['Currency'] ?? ''}',
    status: '${json['status'] ?? json['Status'] ?? ''}',
    provider: '${json['provider'] ?? json['Provider'] ?? ''}',
    checkoutUrl: (json['checkoutUrl'] ?? json['CheckoutUrl'])?.toString(),
    paidAt: _dateOf(json['paidAt'] ?? json['PaidAt']),
    createdAt:
        _dateOf(json['createdAt'] ?? json['CreatedAt']) ?? DateTime(1970),
  );
}

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

  Future<List<PaymentOrder>> getMyOrders() async {
    try {
      final res = await _dio.get(ApiConstants.billingMyOrders);
      final data = res.data;
      final status = res.statusCode ?? 0;

      if (status >= 200 && status < 300 && data is List) {
        return data
            .whereType<Map>()
            .map((e) => PaymentOrder.fromJson(Map<String, dynamic>.from(e)))
            .toList();
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

int _intOf(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateOf(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
