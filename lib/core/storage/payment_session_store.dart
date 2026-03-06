import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PaymentSession {
  final String paymentUrl;
  final DateTime expireAt;

  const PaymentSession({required this.paymentUrl, required this.expireAt});

  bool get isExpired => DateTime.now().isAfter(expireAt);
}

class PaymentSessionStore {
  static const _prefix = 'payment_session_';

  static Future<void> save({
    required int bookingId,
    required String paymentUrl,
    required DateTime expireAt,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'paymentUrl': paymentUrl,
      'expireAt': expireAt.toIso8601String(),
    });
    await sp.setString('$_prefix$bookingId', payload);
  }

  static Future<PaymentSession?> get(int bookingId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('$_prefix$bookingId');
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final paymentUrl = json['paymentUrl']?.toString() ?? '';
      final expireRaw = json['expireAt']?.toString() ?? '';
      if (paymentUrl.isEmpty || expireRaw.isEmpty) return null;
      final expireAt = DateTime.tryParse(expireRaw);
      if (expireAt == null) return null;
      return PaymentSession(paymentUrl: paymentUrl, expireAt: expireAt);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(int bookingId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('$_prefix$bookingId');
  }
}
