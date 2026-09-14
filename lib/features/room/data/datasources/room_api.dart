import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'room_api.g.dart';

@RestApi()
abstract class RoomApi {
  factory RoomApi(Dio dio, {String? baseUrl}) = _RoomApi;

  @GET('/rooms')
  Future<ApiResponse> byHotel(
    @Query('hotelId') int hotelId,
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/rooms/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @GET('/rooms/available')
  Future<ApiResponse> available(
    @Query('hotelId') int hotelId,
    @Query('checkinDate') String checkinDate,
    @Query('checkoutDate') String checkoutDate,
  );

  @POST('/rooms')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/rooms/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/rooms/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  @POST('/rooms/{id}/images')
  @MultiPart()
  Future<ApiResponse> uploadImages(
    @Path('id') int id,
    @Part(name: 'files') List<MultipartFile> files,
  );
}

@module
abstract class RoomApiModule {
  @lazySingleton
  RoomApi roomApi(Dio dio) => RoomApi(dio);
}
