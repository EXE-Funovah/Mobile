import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/core/constants/ai_base_url_resolver.dart';

void main() {
  group('resolveAiBaseUrl', () {
    test('prefers explicit override', () {
      final result = resolveAiBaseUrl(
        overrideBaseUrl: 'http://192.168.1.10:5001',
        isDebugMode: true,
        isWebRuntime: false,
      );

      expect(result, 'http://192.168.1.10:5001');
    });

    test('debug mặc định dùng AI dev deploy (đi cặp backend api-dev)', () {
      for (final isWeb in [true, false]) {
        final result = resolveAiBaseUrl(
          overrideBaseUrl: '',
          isDebugMode: true,
          isWebRuntime: isWeb,
        );

        // KHÔNG trỏ localhost/10.0.2.2 — máy dev thường không chạy AI local,
        // sẽ gây "Connection refused" khi tạo câu hỏi.
        expect(result, 'https://ai-dev.mascoteach.com');
      }
    });

    test(
      'uses production AI service outside debug when no override exists',
      () {
        final result = resolveAiBaseUrl(
          overrideBaseUrl: '',
          isDebugMode: false,
          isWebRuntime: false,
        );

        expect(result, 'https://ai.mascoteach.com');
      },
    );
  });
}
