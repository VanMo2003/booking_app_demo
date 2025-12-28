import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../di/injector.dart';
import 'app_config.dart';
import '../storage/app_prefs.dart';
import 'auth_interceptor.dart';

@injectable
class DioClient {
  final Dio _dio;
  final AppConfig _config = AppConfig();

  DioClient._internal(this._dio) {
    _setupInterceptors();
  }

  static DioClient? _instance;

  /// Initialize the singleton instance. Call this once during app startup.
  static Future<DioClient> init({Dio? dio}) async {
    if (_instance != null) return _instance!;

    final cfg = AppConfig();

    final options = BaseOptions(
      baseUrl: cfg.baseURL,
      connectTimeout: Duration(milliseconds: cfg.connectTimeout),
      sendTimeout: Duration(milliseconds: cfg.sendTimeout),
      receiveTimeout: Duration(milliseconds: cfg.receiveTimeout),
      contentType: cfg.contentType,
      headers: cfg.standardHeaders,
    );

    final _dio = dio ?? Dio(options);
    getIt.registerSingleton<Dio>(_dio);

    _instance = DioClient._internal(_dio);
    return _instance!;
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();

    final secureStorage = FlutterSecureStorage();

    // 🔐 Auth + Refresh token interceptor
    _dio.interceptors.add(
      AuthInterceptor(_dio, secureStorage),
    );

    // Logging (simple)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  /// Helper: GET
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final res = await _dio.get<T>(path,
          queryParameters: queryParameters, options: options);
      return res;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Helper: POST
  Future<Response<T>> post<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final res = await _dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options);
      return res;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Helper: PUT
  Future<Response<T>> put<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final res = await _dio.put<T>(path,
          data: data, queryParameters: queryParameters, options: options);
      return res;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Helper: DELETE
  Future<Response<T>> delete<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final res = await _dio.delete<T>(path,
          data: data, queryParameters: queryParameters, options: options);
      return res;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Set (or update) the auth token for subsequent requests
  Future<void> setAuthToken(String token) async {
    await AppPrefs.setToken(token);
  }

  /// Clear stored token
  Future<void> clearAuthToken() async {
    await AppPrefs.setToken('');
  }

  /// Convert DioError into readable Exception
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout');
    }

    if (e.response != null) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      return Exception('HTTP $status: ${data ?? e.message}');
    }

    return Exception(e.message);
  }
}
