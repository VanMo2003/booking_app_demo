import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'amenity_api.g.dart';

@RestApi()
abstract class AmenityApi {
  factory AmenityApi(Dio dio, {String? baseUrl}) = _AmenityApi;

  /// Chỉ trả tiện ích chung (`common = true`).
  @GET('/amenities/hotel/{hotelId}')
  Future<ApiResponse> byHotel(@Path('hotelId') int hotelId);

  @GET('/amenities/room')
  Future<ApiResponse> byRoom(
    @Query('hotelId') int hotelId,
    @Query('roomId') int roomId,
  );

  @POST('/amenities')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/amenities/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/amenities/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  /// Gắn một tiện ích có sẵn vào phòng khác.
  @POST('/roomAmenitys')
  Future<ApiResponse> linkToRoom(@Body() Map<String, dynamic> body);
}

@module
abstract class AmenityApiModule {
  @lazySingleton
  AmenityApi amenityApi(Dio dio) => AmenityApi(dio);
}
