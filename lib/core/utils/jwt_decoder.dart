import 'dart:convert';

/// Đọc payload JWT phía client (không kiểm chữ ký — việc đó do BE làm).
abstract final class JwtDecoder {
  static Map<String, dynamic>? payload(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? expiry(String? token) {
    final exp = payload(token)?['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  /// Hết hạn (có trừ hao 30 giây để tránh gửi token sắp chết).
  static bool isExpired(
    String? token, {
    Duration leeway = const Duration(seconds: 30),
  }) {
    final exp = expiry(token);
    if (exp == null) return true;
    return DateTime.now().add(leeway).isAfter(exp);
  }

  /// `sub` của token BE là username.
  static String? subject(String? token) => payload(token)?['sub'] as String?;
}
