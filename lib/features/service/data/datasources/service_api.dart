import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'service_api.g.dart';

@RestApi()
abstract class ServiceApi {
  factory ServiceApi(Dio dio, {String? baseUrl}) = _ServiceApi;

  @GET('/services')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  @POST('/services')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/services/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/services/{id}')
  Future<ApiResponse> delete(@Path('id') int id);
}

@module
abstract class ServiceApiModule {
  @lazySingleton
  ServiceApi serviceApi(Dio dio) => ServiceApi(dio);
}
