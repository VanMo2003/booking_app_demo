import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';

part 'room_type_api_service.g.dart';

@RestApi()
abstract class RoomTypeApiService {
  factory RoomTypeApiService(Dio dio, {String? baseUrl}) = _RoomTypeApiService;

  @GET('/roomTypes')
  Future<ApiResponse> getRoomTypes();

  @POST('/roomTypes')
  Future<ApiResponse> createRoomType(@Body() Map<String, dynamic> body);

  @PUT('/roomTypes/{id}')
  Future<ApiResponse> updateRoomType(
      @Path('id') int id, @Body() Map<String, dynamic> body);

  @DELETE('/roomTypes/{id}')
  Future<ApiResponse> deleteRoomType(@Path('id') int id);
}
