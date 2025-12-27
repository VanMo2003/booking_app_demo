import 'package:booking_app_mobile/features/auth/data/datasource/remote/login_api_service.dart';
import 'package:booking_app_mobile/features/position/data/datasource/remote/position_api_service.dart';
import 'package:booking_app_mobile/features/room_type/data/datasource/remote/room_type_api_service.dart';
import 'package:booking_app_mobile/features/room/data/datasource/remote/room_api_service.dart';
import 'package:booking_app_mobile/features/service/data/datasource/remote/service_api_service.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  LoginApiService provideLoanPackageApiService(Dio dio) => LoginApiService(dio);

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
}
