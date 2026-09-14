import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../utils/jwt_decoder.dart';
import 'session_events.dart';

/// Gắn `Authorization: Bearer` và tự làm mới token.
///
/// BE trả 401 cho cả API công khai nếu token gửi kèm đã hết hạn, nên hạn token
/// được kiểm tra *trước* khi gửi: hết hạn thì làm mới; làm mới thất bại thì gửi
/// không kèm token để các màn duyệt công khai vẫn chạy. Nhiều request cùng lúc
/// chỉ tạo đúng một lần gọi `/auth/refreshToken`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokens,
    required SessionEvents events,
    List<Interceptor> retryInterceptors = const [],
  })  : _tokens = tokens,
        _events = events,
        _retryInterceptors = retryInterceptors;

  final TokenStorage _tokens;
  final SessionEvents _events;

  /// Interceptor gắn thêm vào client làm mới token / gửi lại request
  /// (ví dụ trình xem request) để các request này cũng được ghi lại.
  final List<Interceptor> _retryInterceptors;

  /// Đặt `extra[skipAuth] = true` để gửi request không kèm token.
  static const skipAuth = 'skipAuth';
  static const _retried = 'authRetried';
  static const _refreshPath = '/auth/refreshToken';

  Completer<bool>? _refreshing;

  late final Dio _plainClient = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
    ),
  )..interceptors.addAll(_retryInterceptors);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuth] == true ||
        options.path.endsWith(_refreshPath)) {
      return handler.next(options);
    }
    await _tokens.load();
    var access = _tokens.accessToken;
    if (access != null && JwtDecoder.isExpired(access)) {
      access = await _refresh() ? _tokens.accessToken : null;
    }
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sentToken = options.headers.containsKey('Authorization');
    final canRetry = err.response?.statusCode == 401 &&
        sentToken &&
        options.extra[_retried] != true &&
        !options.path.endsWith(_refreshPath);
    if (!canRetry) return handler.next(err);

    if (!await _refresh()) return handler.next(err);

    try {
      options.extra[_retried] = true;
      options.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
      // Gửi lại qua client không có interceptor xác thực để tránh vòng lặp.
      final response = await _plainClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;
    final completer = Completer<bool>();
    _refreshing = completer;
    _performRefresh()
        .then(completer.complete)
        .catchError((Object _) => completer.complete(false))
        .whenComplete(() => _refreshing = null);
    return completer.future;
  }

  Future<bool> _performRefresh() async {
    final refresh = _tokens.refreshToken;
    if (refresh == null ||
        refresh.isEmpty ||
        JwtDecoder.isExpired(refresh, leeway: Duration.zero)) {
      await _expireSession();
      return false;
    }
    try {
      final response = await _plainClient.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'token': refresh},
      );
      final data = response.data?['data'];
      final access = data is Map ? data['accessToken'] as String? : null;
      final nextRefresh = data is Map ? data['refreshToken'] as String? : null;
      if (access == null || nextRefresh == null) {
        await _expireSession();
        return false;
      }
      await _tokens.save(accessToken: access, refreshToken: nextRefresh);
      return true;
    } on DioException {
      await _expireSession();
      return false;
    }
  }

  Future<void> _expireSession() async {
    final hadSession = _tokens.hasSession;
    await _tokens.clear();
    if (hadSession) _events.notifyExpired();
  }
}
