import 'package:booking_app_mobile/features/position/data/datasource/remote/position_api_service.dart';
import 'package:booking_app_mobile/features/room_type/data/datasource/remote/room_type_api_service.dart';
import 'package:booking_app_mobile/features/room/data/datasource/remote/room_api_service.dart';
import 'package:booking_app_mobile/features/service/data/datasource/remote/service_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasource/remote/auth_api_service.dart';
import '../../features/customer/data/datasource/remote/customer_api_service.dart';
import '../api/app_config.dart';
import '../api/auth_interceptor.dart';
import '../api/dio_client.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  FlutterSecureStorage provideSecureStorage() => const FlutterSecureStorage();

  @lazySingleton
  Dio provideDio(FlutterSecureStorage storage) {
    final cfg = AppConfig();

    final dio = Dio(
      BaseOptions(
        baseUrl: cfg.baseURL,
        connectTimeout: Duration(milliseconds: cfg.connectTimeout),
        sendTimeout: Duration(milliseconds: cfg.sendTimeout),
        receiveTimeout: Duration(milliseconds: cfg.receiveTimeout),
        contentType: cfg.contentType,
        headers: cfg.standardHeaders,
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio, storage));
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  @lazySingleton
  DioClient provideDioClient(Dio dio) => DioClient(dio);

  @lazySingleton
  AuthApiService provideAuthApiService(Dio dio) => AuthApiService(dio);

  @lazySingleton
  PositionApiService providePositionApiService(Dio dio) =>
      PositionApiService(dio);

  @lazySingleton
  RoomTypeApiService provideRoomTypeApiService(Dio dio) =>
      RoomTypeApiService(dio);

  @lazySingleton
  RoomApiService provideRoomApiService(Dio dio) => RoomApiService(dio);

  @lazySingleton
  ServiceApiService provideServiceApiService(Dio dio) => ServiceApiService(dio);

  @lazySingleton
  CustomerApiService provideCustomerApiService(Dio dio) =>
      CustomerApiService(dio);
}
