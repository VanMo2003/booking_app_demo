import 'package:booking_app_mobile/features/share/data/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/constant.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;

  bool _isRefreshing = false;
  final List<Function()> _retryQueue = [];

  AuthInterceptor(this.dio, this.storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.read(key: Constants.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['retry'] != true &&
        !err.requestOptions.path.contains('/auth/refreshToken')) {
      err.requestOptions.extra['retry'] = true;

      if (_isRefreshing) {
        _retryQueue.add(() async {
          final access = await storage.read(key: Constants.accessToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $access';
          handler.resolve(await dio.fetch(err.requestOptions));
        });
        return;
      }

      _isRefreshing = true;

      final refreshed = await _refreshToken();

      _isRefreshing = false;

      if (refreshed) {
        final access = await storage.read(key: Constants.accessToken);
        err.requestOptions.headers['Authorization'] = 'Bearer $access';

        // retry các request đang chờ
        for (final retry in _retryQueue) {
          retry();
        }
        _retryQueue.clear();

        return handler.resolve(await dio.fetch(err.requestOptions));
      } else {
        _retryQueue.clear();
        handler.next(err);
        return;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: Constants.refreshToken);
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

      await storage.write(key: Constants.accessToken, value: newAccess);
      await storage.write(key: Constants.refreshToken, value: newRefresh);
      return true;
    } catch (e) {
      await storage.deleteAll();
      return false;
    }
  }
}
