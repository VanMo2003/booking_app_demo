import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'catalog_api.g.dart';

@RestApi()
abstract class CatalogApi {
  factory CatalogApi(Dio dio, {String? baseUrl}) = _CatalogApi;

  @GET('/roomTypes')
  Future<ApiResponse> roomTypes();

  @POST('/roomTypes')
  Future<ApiResponse> createRoomType(@Body() Map<String, dynamic> body);

  @PUT('/roomTypes/{id}')
  Future<ApiResponse> updateRoomType(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/roomTypes/{id}')
  Future<ApiResponse> deleteRoomType(@Path('id') int id);

  @GET('/positions')
  Future<ApiResponse> positions();

  @POST('/positions')
  Future<ApiResponse> createPosition(@Body() Map<String, dynamic> body);

  @PUT('/positions/{id}')
  Future<ApiResponse> updatePosition(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/positions/{id}')
  Future<ApiResponse> deletePosition(@Path('id') int id);
}

@module
abstract class CatalogApiModule {
  @lazySingleton
  CatalogApi catalogApi(Dio dio) => CatalogApi(dio);
}
