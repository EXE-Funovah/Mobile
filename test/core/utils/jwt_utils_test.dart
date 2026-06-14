import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/core/utils/jwt_utils.dart';

String _fakeJwt(Map<String, dynamic> payload) {
  String enc(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(json.encode(m))).replaceAll('=', '');
  return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.fakesig';
}

void main() {
  final now = DateTime.utc(2026, 6, 12, 12, 0, 0);
  int epoch(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

  group('isJwtExpired', () {
    test('token còn hạn → false', () {
      final token = _fakeJwt({
        'exp': epoch(now.add(const Duration(minutes: 30))),
      });
      expect(isJwtExpired(token, now: now), isFalse);
    });

    test('token quá hạn → true', () {
      final token = _fakeJwt({
        'exp': epoch(now.subtract(const Duration(minutes: 5))),
      });
      expect(isJwtExpired(token, now: now), isTrue);
    });

    test('token hết hạn đúng thời điểm exp → true', () {
      final token = _fakeJwt({'exp': epoch(now)});
      expect(isJwtExpired(token, now: now), isTrue);
    });

    test('token dị dạng hoặc thiếu exp → coi như hết hạn', () {
      expect(isJwtExpired('not-a-jwt', now: now), isTrue);
      expect(isJwtExpired('a.b', now: now), isTrue);
      expect(isJwtExpired(_fakeJwt({'sub': '1'}), now: now), isTrue);
      expect(isJwtExpired(_fakeJwt({'exp': 'oops'}), now: now), isTrue);
    });
  });
}
