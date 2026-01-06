import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';
import '../../models/request/amenity_create_request.dart';
import '../../models/request/amenity_update_request.dart';

part 'amenity_api_service.g.dart';

@RestApi()
abstract class AmenityApiService {
  factory AmenityApiService(Dio dio, {String? baseUrl}) = _AmenityApiService;

  @POST('/amenities')
  Future<ApiResponse> createAmenity(@Body() AmenityCreateRequest body);

  @PUT('/amenities/{id}')
  Future<ApiResponse> updateAmenity(
    @Path('id') int id,
    @Body() AmenityUpdateRequest body,
  );

  @GET('/amenities/hotel/{hotelId}')
  Future<ApiResponse> getAmenitiesByHotel(@Path('hotelId') int hotelId);

  @GET('/amenities/room')
  Future<ApiResponse> getAmenitiesByRoom(
    @Query('hotelId') int hotelId,
    @Query('roomId') int roomId,
  );

  @DELETE('/amenities/{id}')
  Future<ApiResponse> deleteAmenity(@Path('id') int id);
}
