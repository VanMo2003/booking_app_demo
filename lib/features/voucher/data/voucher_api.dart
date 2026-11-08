import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_response.dart';

part 'voucher_api.g.dart';

@RestApi()
abstract class VoucherApi {
  factory VoucherApi(Dio dio, {String? baseUrl}) = _VoucherApi;

  /// Công khai: mã dùng được hôm nay ở một cơ sở, hoặc mọi nơi.
  @GET('/vouchers/available')
  Future<ApiResponse> available(@Query('hotelId') int? hotelId);

  @POST('/vouchers/check')
  Future<ApiResponse> check(@Body() Map<String, dynamic> body);

  /// Danh sách của đội ngũ: của chuỗi ([hotelChainId]) hoặc của một cơ sở ([hotelId]).
  @GET('/vouchers')
  Future<ApiResponse> list(@Query('hotelChainId') int? hotelChainId, @Query('hotelId') int? hotelId);

  @POST('/vouchers')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/vouchers/{id}')
  Future<ApiResponse> update(@Path('id') int id, @Body() Map<String, dynamic> body);

  @DELETE('/vouchers/{id}')
  Future<ApiResponse> delete(@Path('id') int id);
}

@module
abstract class VoucherApiModule {
  @lazySingleton
  VoucherApi voucherApi(Dio dio) => VoucherApi(dio);
}
