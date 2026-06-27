import '../data/admin_models.dart';

/// Tiền VND có dấu chấm: 1188000 -> "1.188.000".
String vnd(num n) {
  final s = n.round().abs().toString();
  final buf = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Số gọn: 1243800 -> "1,24M" · 3450 -> "3,5K".
String compactNum(num n) {
  if (n.abs() >= 1e9) return '${_fix(n / 1e9, 2)} tỷ';
  if (n.abs() >= 1e6) return '${_fix(n / 1e6, 2)}M';
  if (n.abs() >= 1e3) return '${_fix(n / 1e3, 1)}K';
  return vnd(n);
}

/// Tiền gọn: 412500000 -> "412,5tr" · 4950000000 -> "4,95 tỷ".
String vndShort(num n) {
  if (n.abs() >= 1e9) return '${_fix(n / 1e9, 2)} tỷ';
  if (n.abs() >= 1e6) return '${_fix(n / 1e6, 1)}tr';
  if (n.abs() >= 1e3) return '${(n / 1e3).round()}K';
  return vnd(n);
}

String _fix(num v, int d) {
  var s = v.toStringAsFixed(d);
  // bỏ số 0 thừa cuối, dùng dấu phẩy kiểu VN
  s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return s.replaceAll('.', ',');
}

/// Format giá trị KPI theo `format` từ backend.
String formatKpi(AdminKpi k) {
  switch (k.format) {
    case 'currency':
      return vndShort(k.value);
    case 'percent':
      return '${_fix(k.value, 1)}%';
    default:
      return vnd(k.value);
  }
}
