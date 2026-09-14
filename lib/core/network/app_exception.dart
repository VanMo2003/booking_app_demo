import 'dart:convert';

import 'package:dio/dio.dart';

import '../text/error_strings.dart';

/// Lỗi chuẩn hoá của app. Repository ném lỗi này; cubit chỉ việc lấy
/// [message] (đã là tiếng Việt) để hiển thị.
class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return AppException.fromDio(error);
    return const AppException(ErrorStrings.unknown);
  }

  factory AppException.fromDio(DioException error) {
    final inner = error.error;
    if (inner is AppException) return inner;

    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const AppException(ErrorStrings.timeout);
    }
    if (type == DioExceptionType.connectionError) {
      return const AppException(ErrorStrings.network);
    }
    if (type == DioExceptionType.cancel) {
      return const AppException(ErrorStrings.cancelled);
    }

    final response = error.response;
    final status = response?.statusCode;
    final body = _decodeBody(response?.data);
    final rawCode = body?['code'];
    final code = rawCode is num ? rawCode.toInt() : null;
    final message = ErrorStrings.translate(
      body?['message']?.toString(),
      code: code,
      status: status,
    );
    if (status == null && body == null) {
      return const AppException(ErrorStrings.network);
    }
    return AppException(message, code: code, statusCode: status);
  }

  final String message;
  final int? code;
  final int? statusCode;

  bool get isUnauthenticated => statusCode == 401 || code == 1001;
  bool get isForbidden => statusCode == 403 && code != 403;
  bool get isNotFound => statusCode == 404;

  /// Body lỗi có thể là JSON đã parse, chuỗi, hoặc bytes (API xuất Excel).
  static Map<String, dynamic>? _decodeBody(Object? data) {
    try {
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data is String && data.isNotEmpty) {
        final decoded = jsonDecode(data);
        return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      }
      if (data is List<int> && data.isNotEmpty) {
        final decoded = jsonDecode(utf8.decode(data));
        return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  String toString() => message;
}
