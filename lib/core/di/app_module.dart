import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/auth_interceptor.dart';
import '../network/connectivity_interceptor.dart';
import '../network/network_status.dart';
import '../network/session_events.dart';
import '../storage/token_storage.dart';

@module
abstract class AppModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  Dio dio(TokenStorage tokens, SessionEvents events, NetworkStatus network) {
    // Trình xem request chỉ chạy ở bản debug (khớp `enabled` trong main.dart).
    final inspector = <Interceptor>[if (kDebugMode) RequestsInspectorInterceptor()];
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(tokens: tokens, events: events, retryInterceptors: inspector),
      ConnectivityInterceptor(network),
      ...inspector,
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          logPrint: (line) => debugPrint(line.toString()),
        ),
    ]);
    return dio;
  }
}
