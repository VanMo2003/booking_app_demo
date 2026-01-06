import 'package:booking_app_mobile/features/employee/data/models/request/employee_create_request.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_update_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';

part 'employee_api_service.g.dart';

@RestApi()
abstract class EmployeeApiService {
  factory EmployeeApiService(Dio dio, {String? baseUrl}) = _EmployeeApiService;

  @GET('/employees/by-hotel')
  Future<ApiResponse> getEmployeesByHotel(
      @Query('hotelId') int hotelId,
      );

  @POST('/employees')
  Future<ApiResponse> createEmployee(
      @Body() EmployeeCreateRequest body,
      );

  @PUT('/employees/{id}')
  Future<ApiResponse> updateEmployee(
      @Path('id') int id,
      @Body() EmployeeUpdateRequest body,
      );

  @DELETE('/employees/{id}')
  Future<ApiResponse> deleteEmployee(
      @Path('id') int id,
      );
}
