import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'tour_api.g.dart';

@RestApi()
abstract class TourApi {
  factory TourApi(Dio dio, {String? baseUrl}) = _TourApi;

  @GET('/tours')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  @POST('/tours')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/tours/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// Phòng của gói còn trống cho kỳ ở bắt đầu từ ngày đi tour.
  @GET('/tours/{id}/rooms/available')
  Future<ApiResponse> availableRooms(@Path('id') int id, @Query('date') String date);

  @DELETE('/tours/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  /// BE nhận đúng một part `file`; retrofit chỉ sinh được part file dạng danh sách.
  @POST('/tours/{id}/image')
  @MultiPart()
  Future<ApiResponse> uploadImage(
    @Path('id') int id,
    @Part(name: 'file') List<MultipartFile> file,
  );
}

@module
abstract class TourApiModule {
  @lazySingleton
  TourApi tourApi(Dio dio) => TourApi(dio);
}
