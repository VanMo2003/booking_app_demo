import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthInterceptor(this.dio, this.storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final access = await storage.read(key: 'access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $access';
        return handler.resolve(await dio.fetch(err.requestOptions));
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(baseUrl: dio.options.baseUrl),
      );
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccess = response.data['access_token'];
      final newRefresh = response.data['refresh_token'];

      await storage.write(key: 'access_token', value: newAccess);
      await storage.write(key: 'refresh_token', value: newRefresh);
      return true;
    } catch (_) {
      await storage.deleteAll();
      return false;
    }
  }
}
