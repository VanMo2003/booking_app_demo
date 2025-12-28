import 'package:booking_app_mobile/features/share/data/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/key_constant.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthInterceptor(this.dio, this.storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.read(key: KeyConstant.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refreshToken')) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final access = await storage.read(key: KeyConstant.accessToken);
        err.requestOptions.headers['Authorization'] = 'Bearer $access';
        return handler.resolve(await dio.fetch(err.requestOptions));
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: KeyConstant.refreshToken);
    if (refreshToken == null) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await refreshDio.post(
        '/auth/refreshToken',
        data: {'token': refreshToken},
      );

      var res = ApiResponse.fromJson(response.data);

      final newAccess = res.data['accessToken'];
      final newRefresh = res.data['refreshToken'];

      await storage.write(key: KeyConstant.accessToken, value: newAccess);
      await storage.write(key: KeyConstant.refreshToken, value: newRefresh);
      return true;
    } catch (e) {
      await storage.deleteAll();
      return false;
    }
  }
}
