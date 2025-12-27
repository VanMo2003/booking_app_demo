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
  Future<ApiResponse> createPosition(@Body() Map<String, dynamic> body);

  @PUT('/positions/{id}')
  Future<ApiResponse> updatePosition(
      @Path('id') int id, @Body() Map<String, dynamic> body);

  @DELETE('/positions/{id}')
  Future<ApiResponse> deletePosition(@Path('id') int id);
}
