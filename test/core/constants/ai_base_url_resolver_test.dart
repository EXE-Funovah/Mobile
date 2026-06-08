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

    test('uses Android emulator local AI service in debug by default', () {
      final result = resolveAiBaseUrl(
        overrideBaseUrl: '',
        isDebugMode: true,
        isWebRuntime: false,
      );

      expect(result, 'http://10.0.2.2:5001');
    });

    test('uses localhost for web debug by default', () {
      final result = resolveAiBaseUrl(
        overrideBaseUrl: '',
        isDebugMode: true,
        isWebRuntime: true,
      );

      expect(result, 'http://localhost:5001');
    });

    test('uses production AI service outside debug when no override exists', () {
      final result = resolveAiBaseUrl(
        overrideBaseUrl: '',
        isDebugMode: false,
        isWebRuntime: false,
      );

      expect(result, 'https://ai.mascoteach.com');
    });
  });
}
