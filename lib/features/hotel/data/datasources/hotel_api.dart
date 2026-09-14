import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'hotel_api.g.dart';

@RestApi()
abstract class HotelApi {
  factory HotelApi(Dio dio, {String? baseUrl}) = _HotelApi;

  /// Công khai, có phân trang.
  @GET('/hotels')
  Future<ApiResponse> getHotels(@Query('page') int page, @Query('size') int size);

  /// Công khai; mỗi cơ sở có thêm `status` AVAILABLE/FULL/INACTIVE.
  @GET('/hotels/search')
  Future<ApiResponse> search(
    @Query('checkinDate') String checkinDate,
    @Query('checkoutDate') String checkoutDate,
  );

  @GET('/hotels/category')
  Future<ApiResponse> byCategory(@Query('name') String name);

  /// Gửi đủ hai ngày hoặc không gửi ngày nào.
  @GET('/hotels/detail/{id}')
  Future<ApiResponse> detail(
    @Path('id') int id, {
    @Query('checkinDate') String? checkinDate,
    @Query('checkoutDate') String? checkoutDate,
  });

  /// `data` là một phần JSON duy nhất, khai báo dạng danh sách vì Retrofit
  /// chỉ nhận `MultipartFile` trong list.
  @POST('/hotels')
  @MultiPart()
  Future<ApiResponse> create(
    @Part(name: 'data') List<MultipartFile> data,
    @Part(name: 'files') List<MultipartFile> files,
  );

  @PUT('/hotels/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/hotels/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  @POST('/hotels/{id}/images')
  @MultiPart()
  Future<ApiResponse> uploadImages(
    @Path('id') int id,
    @Part(name: 'files') List<MultipartFile> files,
  );
}

@module
abstract class HotelApiModule {
  @lazySingleton
  HotelApi hotelApi(Dio dio) => HotelApi(dio);
}
