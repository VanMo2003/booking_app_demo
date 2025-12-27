import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';
import '../../models/request/room_type_create_dto.dart';
import '../../models/request/room_type_update_dto.dart';

part 'room_type_api_service.g.dart';

@RestApi()
abstract class RoomTypeApiService {
  factory RoomTypeApiService(Dio dio, {String? baseUrl}) = _RoomTypeApiService;

  @GET('/roomTypes')
  Future<ApiResponse> getRoomTypes();

  @POST('/roomTypes')
  Future<ApiResponse> createRoomType(@Body() RoomTypeCreateDto body);

  @PUT('/roomTypes/{id}')
  Future<ApiResponse> updateRoomType(
      @Path('id') int id, @Body() RoomTypeUpdateDto body);

  @DELETE('/roomTypes/{id}')
  Future<ApiResponse> deleteRoomType(@Path('id') int id);
}
