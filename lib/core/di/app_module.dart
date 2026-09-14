import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/auth_interceptor.dart';
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
  Dio dio(TokenStorage tokens, SessionEvents events) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(AuthInterceptor(tokens: tokens, events: events));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          logPrint: (line) => debugPrint(line.toString()),
        ),
      );
    }
    return dio;
  }
}
