import 'dart:convert';

/// Standardized exception used across the app for API/errors.
/// Its `toString()` returns a JSON string like:
/// {"success":false,"message":"...","code":401}
class AppException implements Exception {
  final bool success = false;
  final String message;
  final int code;

  AppException({required this.message, required this.code});

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'code': code,
      };

  @override
  String toString() => jsonEncode(toJson());
}
