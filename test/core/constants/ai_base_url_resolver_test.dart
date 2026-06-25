import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/core/constants/ai_base_url_resolver.dart';

void main() {
  group('resolveAiBaseUrl', () {
    test('ưu tiên override (dart-define) khi có', () {
      final result = resolveAiBaseUrl(
        overrideBaseUrl: 'https://ai.mascoteach.com',
        isDebugMode: false,
        isWebRuntime: false,
      );

      expect(result, 'https://ai.mascoteach.com');
    });

    test('mặc định dùng AI PROD khi không có override (mọi mode)', () {
      for (final isDebug in [true, false]) {
        for (final isWeb in [true, false]) {
          final result = resolveAiBaseUrl(
            overrideBaseUrl: '',
            isDebugMode: isDebug,
            isWebRuntime: isWeb,
          );
          expect(result, 'https://ai.mascoteach.com');
        }
      }
    });
  });
}
