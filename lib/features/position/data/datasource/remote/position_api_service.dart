import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';
import 'package:booking_app_mobile/features/position/data/models/request/position_update_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';

part 'position_api_service.g.dart';

@RestApi()
abstract class PositionApiService {
  factory PositionApiService(Dio dio, {String? baseUrl}) = _PositionApiService;

  @GET('/positions')
  Future<ApiResponse> getPosition();

  @POST('/positions')
  Future<ApiResponse> createPosition(@Body() PositionCreateDto body);

  @PUT('/positions/{id}')
  Future<ApiResponse> updatePosition(
      @Path('id') int id, @Body() PositionUpdateDto body);

  @DELETE('/positions/{id}')
  Future<ApiResponse> deletePosition(@Path('id') int id);
}
