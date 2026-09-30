import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'chat_api.g.dart';

@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio, {String? baseUrl}) = _ChatApi;

  @POST('/conversations')
  Future<ApiResponse> open(@Body() Map<String, dynamic> body);

  @GET('/conversations/me')
  Future<ApiResponse> mine(@Query('page') int page, @Query('size') int size);

  @GET('/conversations/inbox')
  Future<ApiResponse> inbox(
    @Query('hotelId') int? hotelId,
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/conversations/unread-count')
  Future<ApiResponse> unreadCount(@Query('hotelId') int? hotelId);

  @GET('/conversations/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @GET('/conversations/{id}/messages')
  Future<ApiResponse> messages(
    @Path('id') int id,
    @Query('beforeId') int? beforeId,
    @Query('size') int size,
  );

  @POST('/conversations/{id}/messages')
  Future<ApiResponse> send(@Path('id') int id, @Body() Map<String, dynamic> body);

  @PUT('/conversations/{id}/read')
  Future<ApiResponse> markRead(@Path('id') int id);
}

@module
abstract class ChatApiModule {
  @lazySingleton
  ChatApi chatApi(Dio dio) => ChatApi(dio);
}
