import 'package:booking_app_mobile/features/auth/data/models/response/employee_response.dart';
import 'package:booking_app_mobile/features/employee/data/datasource/remote/employee_api_service.dart';
import 'package:booking_app_mobile/features/employee/data/mapper/employee_mapper.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_create_request.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_update_request.dart';
import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/dio_client.dart';
import '../../domain/repositories/employee_repository.dart';

@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeApiService apiService;
  final DioClient dioClient;

  EmployeeRepositoryImpl({required this.apiService, required this.dioClient});

  @override
  Future<Employee> create(EmployeeCreateRequest req) async {
    try {
      final response = await apiService.createEmployee(req);
      final data = response.data;
      return EmployeeMapper.toEntity(EmployeeResponse.fromJson(data));
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await apiService.deleteEmployee(id);
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<List<Employee>> getByHotel({required int hotelId}) async {
    try {
      final response = await apiService.getEmployeesByHotel(hotelId);

      List<Employee>? items;
      items ??= [];

      for (var item in response.data) {
        items.add(EmployeeMapper.toEntity(EmployeeResponse.fromJson(item)));
      }

      return items;
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<Employee> update(int id, EmployeeUpdateRequest req) async {
    try {
      final response = await apiService.updateEmployee(id, req);
      final data = response.data;
      return EmployeeMapper.toEntity(EmployeeResponse.fromJson(data));
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
