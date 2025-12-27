import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../share/data/models/api_response.dart';
import '../../models/request/service_create_dto.dart';
import '../../models/request/service_update_dto.dart';

part 'service_api_service.g.dart';

@RestApi()
abstract class ServiceApiService {
  factory ServiceApiService(Dio dio, {String? baseUrl}) = _ServiceApiService;

  @GET('/services')
  Future<ApiResponse> getServices(@Query('hotelId') int? hotelId);

  @POST('/services')
  Future<ApiResponse> createService(@Body() ServiceCreateDto body);

  @PUT('/services/{id}')
  Future<ApiResponse> updateService(
      @Path('id') int id, @Body() ServiceUpdateDto body);

  @DELETE('/services/{id}')
  Future<ApiResponse> deleteService(@Path('id') int id);
}
