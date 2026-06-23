import 'dart:convert';

/// Token hết hạn chưa (đọc claim `exp`, epoch giây UTC).
///
/// Token dị dạng coi như hết hạn — backend sẽ từ chối nó kiểu gì cũng 401,
/// thà bắt user login lại sớm còn hơn để app tưởng còn phiên.
bool isJwtExpired(String token, {DateTime? now}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload =
        json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
            )
            as Map<String, dynamic>;
    final exp = payload['exp'];
    if (exp is! int) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    return !(now ?? DateTime.now()).toUtc().isBefore(expiry);
  } catch (_) {
    return true;
  }
}
