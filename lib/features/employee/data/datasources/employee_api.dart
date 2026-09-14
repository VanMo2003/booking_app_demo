import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'employee_api.g.dart';

@RestApi()
abstract class EmployeeApi {
  factory EmployeeApi(Dio dio, {String? baseUrl}) = _EmployeeApi;

  /// Tạo nhân viên kèm tài khoản STAFF.
  @POST('/employees')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/employees/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/employees/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @GET('/employees/by-hotel')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  @GET('/employees')
  Future<ApiResponse> getAll(@Query('page') int page, @Query('size') int size);

  @DELETE('/employees/{id}')
  Future<ApiResponse> delete(@Path('id') int id);
}

@module
abstract class EmployeeApiModule {
  @lazySingleton
  EmployeeApi employeeApi(Dio dio) => EmployeeApi(dio);
}
