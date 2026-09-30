import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'dish_api.g.dart';

@RestApi()
abstract class DishApi {
  factory DishApi(Dio dio, {String? baseUrl}) = _DishApi;

  @GET('/dishes')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  @POST('/dishes')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/dishes/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/dishes/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  /// BE nhận đúng một part `file`; retrofit chỉ sinh được part file dạng danh sách.
  @POST('/dishes/{id}/image')
  @MultiPart()
  Future<ApiResponse> uploadImage(
    @Path('id') int id,
    @Part(name: 'file') List<MultipartFile> file,
  );
}

@module
abstract class DishApiModule {
  @lazySingleton
  DishApi dishApi(Dio dio) => DishApi(dio);
}
