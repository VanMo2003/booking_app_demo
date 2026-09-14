import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'customer_api.g.dart';

@RestApi()
abstract class CustomerApi {
  factory CustomerApi(Dio dio, {String? baseUrl}) = _CustomerApi;

  /// Không có `accountId` → hồ sơ khách vãng lai (chỉ nhân viên trở lên).
  @POST('/customers')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/customers/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/customers/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @GET('/customers')
  Future<ApiResponse> getAll(@Query('page') int page, @Query('size') int size);

  @GET('/customers/by-hotel')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  /// So khớp chính xác số điện thoại.
  @GET('/customers/search')
  Future<ApiResponse> searchByPhone(@Query('phoneNumber') String phoneNumber);

  /// Gắn tài khoản khách vào hồ sơ vãng lai có cùng số điện thoại.
  @POST('/customers/link-by-phone')
  Future<ApiResponse> linkByPhone(@Body() Map<String, dynamic> body);
}

@module
abstract class CustomerApiModule {
  @lazySingleton
  CustomerApi customerApi(Dio dio) => CustomerApi(dio);
}
