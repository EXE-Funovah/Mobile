import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/core/utils/network_error_formatter.dart';

void main() {
  group('formatNetworkError', () {
    test('returns friendly message for 502 responses', () {
      final error = DioException.badResponse(
        statusCode: 502,
        requestOptions: RequestOptions(path: '/ai/chat'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/ai/chat'),
          statusCode: 502,
          data: {'message': 'upstream timeout'},
        ),
      );

      final message = formatNetworkError(
        error,
        fallbackMessage: 'Không gửi được prompt',
      );

      expect(message, contains('502'));
      expect(message, isNot(contains('DioException')));
      expect(message, isNot(contains('stackTrace')));
    });
  });
}
