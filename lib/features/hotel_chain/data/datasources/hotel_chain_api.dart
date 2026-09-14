import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'hotel_chain_api.g.dart';

@RestApi()
abstract class HotelChainApi {
  factory HotelChainApi(Dio dio, {String? baseUrl}) = _HotelChainApi;

  @POST('/hotel-chains')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/hotel-chains/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/hotel-chains/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @GET('/hotel-chains')
  Future<ApiResponse> getAll(@Query('page') int page, @Query('size') int size);

  @DELETE('/hotel-chains/{id}')
  Future<ApiResponse> delete(@Path('id') int id);
}

@module
abstract class HotelChainApiModule {
  @lazySingleton
  HotelChainApi hotelChainApi(Dio dio) => HotelChainApi(dio);
}
