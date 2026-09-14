import 'dart:convert';

import 'package:dio/dio.dart';

import '../text/error_strings.dart';

/// Nhóm lỗi — quyết định màn hình hiện component trạng thái nào.
enum AppErrorKind {
  /// Thiết bị không có kết nối mạng.
  network,

  /// Không gọi được máy chủ (BE chưa chạy, quá thời gian chờ) hoặc máy chủ lỗi 5xx.
  server,

  /// Chưa đăng nhập hoặc phiên đã hết hạn.
  unauthorized,

  /// Tài khoản không có quyền.
  forbidden,

  /// Không tìm thấy dữ liệu.
  notFound,

  /// Dữ liệu gửi lên không hợp lệ.
  badRequest,

  /// Yêu cầu bị huỷ.
  cancelled,

  /// Lỗi không xác định (dữ liệu trả về sai định dạng…).
  unknown;

  /// Lỗi hệ thống — hiện component lỗi hệ thống kèm nút tải lại.
  bool get isSystem => this == server || this == unknown;
}

/// Gắn vào `DioException.error` khi request lỗi lúc thiết bị đang mất mạng
/// (xem `ConnectivityInterceptor`).
class NoInternetException implements Exception {
  const NoInternetException();
}

/// Lỗi chuẩn hoá của app. Repository ném lỗi này; cubit lấy [message] (tiếng Việt)
/// để hiển thị và [kind] để chọn component lỗi phù hợp.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.statusCode,
    this.kind = AppErrorKind.unknown,
  });

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return AppException.fromDio(error);
    if (error is NoInternetException) return _offline;
    return const AppException(ErrorStrings.unknown);
  }

  factory AppException.fromDio(DioException error) {
    final inner = error.error;
    if (inner is AppException) return inner;
    if (inner is NoInternetException) return _offline;

    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const AppException(ErrorStrings.timeout, kind: AppErrorKind.server);
    }
    if (type == DioExceptionType.connectionError) return _unreachable;
    if (type == DioExceptionType.cancel) {
      return const AppException(ErrorStrings.cancelled, kind: AppErrorKind.cancelled);
    }

    final response = error.response;
    final status = response?.statusCode;
    final body = _decodeBody(response?.data);
    if (status == null && body == null) return _unreachable;

    final rawCode = body?['code'];
    final code = rawCode is num ? rawCode.toInt() : null;
    final message = ErrorStrings.translate(
      body?['message']?.toString(),
      code: code,
      status: status,
    );
    return AppException(
      message,
      code: code,
      statusCode: status,
      kind: kindOf(status: status, code: code),
    );
  }

  static const _offline = AppException(ErrorStrings.offline, kind: AppErrorKind.network);
  static const _unreachable =
      AppException(ErrorStrings.serverUnreachable, kind: AppErrorKind.server);

  final String message;
  final int? code;
  final int? statusCode;
  final AppErrorKind kind;

  bool get isUnauthenticated => statusCode == 401 || code == 1001;
  bool get isForbidden => statusCode == 403 && code != 403;
  bool get isNotFound => statusCode == 404;
  bool get isNetwork => kind == AppErrorKind.network;

  /// Nhóm lỗi theo HTTP status và mã lỗi nghiệp vụ của BE.
  static AppErrorKind kindOf({int? status, int? code}) {
    if (status == 401 || code == 1001) return AppErrorKind.unauthorized;
    if (status == 403 || code == 1002) return AppErrorKind.forbidden;
    if (status == 404 || code == 404) return AppErrorKind.notFound;
    if (status != null && status >= 500) return AppErrorKind.server;
    if (status != null && status >= 400) return AppErrorKind.badRequest;
    if (code == 402 || code == 400) return AppErrorKind.badRequest;
    return AppErrorKind.unknown;
  }

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
