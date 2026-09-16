import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'partner_api.g.dart';

/// Hồ sơ đăng ký chủ khách sạn (`/owner-registrations`).
@RestApi()
abstract class PartnerApi {
  factory PartnerApi(Dio dio, {String? baseUrl}) = _PartnerApi;

  /// Công khai: tạo tài khoản HOTEL_OWNER kèm hồ sơ khách sạn chờ duyệt.
  @POST('/owner-registrations')
  @Extra({'skipAuth': true})
  Future<ApiResponse> register(@Body() Map<String, dynamic> body);

  @GET('/owner-registrations/me')
  Future<ApiResponse> getMine();

  @PUT('/owner-registrations/me')
  Future<ApiResponse> resubmit(@Body() Map<String, dynamic> body);

  /// Quản trị viên: hàng chờ duyệt / hồ sơ đã xử lý.
  @GET('/owner-registrations')
  Future<ApiResponse> getAll(
    @Query('status') String? status,
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/owner-registrations/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @PUT('/owner-registrations/{id}/approve')
  Future<ApiResponse> approve(@Path('id') int id);

  @PUT('/owner-registrations/{id}/reject')
  Future<ApiResponse> reject(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );
}

@module
abstract class PartnerApiModule {
  @lazySingleton
  PartnerApi partnerApi(Dio dio) => PartnerApi(dio);
}
