import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../share/data/models/api_response.dart';
import '../../models/request/room_create_dto.dart';
import '../../models/request/room_update_dto.dart';

part 'room_api_service.g.dart';

@RestApi()
abstract class RoomApiService {
  factory RoomApiService(Dio dio, {String? baseUrl}) = _RoomApiService;

  @GET('/rooms')
  Future<ApiResponse> getRooms(
    @Query('hotelId') int? hotelId,
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/rooms/{id}')
  Future<ApiResponse> getRoomById(@Path('id') int id);

  @POST('/rooms')
  Future<ApiResponse> createRoom(@Body() RoomCreateDto body);

  @PUT('/rooms/{id}')
  Future<ApiResponse> updateRoom(
      @Path('id') int id, @Body() RoomUpdateDto body);

  @DELETE('/rooms/{id}')
  Future<ApiResponse> deleteRoom(@Path('id') int id);
}
