import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'notification_api.g.dart';

@RestApi()
abstract class NotificationApi {
  factory NotificationApi(Dio dio, {String? baseUrl}) = _NotificationApi;

  @GET('/notifications')
  Future<ApiResponse> getMine(@Query('page') int page, @Query('size') int size);

  @GET('/notifications/unread-count')
  Future<ApiResponse> unreadCount();

  @PUT('/notifications/{id}/read')
  Future<ApiResponse> markRead(@Path('id') int id);

  @PUT('/notifications/read-all')
  Future<ApiResponse> markAllRead();

  /// Gắn token FCM của thiết bị với tài khoản đang đăng nhập.
  @POST('/notifications/devices')
  Future<ApiResponse> registerDevice(@Body() Map<String, dynamic> body);

  /// Gỡ trước khi đăng xuất để thiết bị không nhận thông báo của tài khoản cũ.
  @DELETE('/notifications/devices')
  Future<ApiResponse> unregisterDevice(@Query('token') String token);
}

@module
abstract class NotificationApiModule {
  @lazySingleton
  NotificationApi notificationApi(Dio dio) => NotificationApi(dio);
}
