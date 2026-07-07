import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/mascot_live_api.dart';

void main() {
  group('MascotLiveApi auth headers', () {
    test('includes bearer token when the user is logged in', () async {
      final api = MascotLiveApi.forTesting(
        tokenReader: () async => 'mobile-jwt-token',
      );

      final headers = await api.authJsonHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer mobile-jwt-token');
    });

    test('omits bearer token when there is no saved login session', () async {
      final api = MascotLiveApi.forTesting(tokenReader: () async => null);

      final headers = await api.authJsonHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });
}
