import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_api.dart';
import '../models/employee_models.dart';

@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(this._api);

  final EmployeeApi _api;

  @override
  Future<Employee> create(EmployeeRequest request) async =>
      (await _api.create(request.toJson())).parse(EmployeeModel.fromJson);

  @override
  Future<Employee> update(int id, EmployeeRequest request) async =>
      (await _api.update(id, request.toJson())).parse(EmployeeModel.fromJson);

  @override
  Future<Employee> getById(int id) async =>
      (await _api.getById(id)).parse(EmployeeModel.fromJson);

  @override
  Future<List<Employee>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(EmployeeModel.fromJson);

  @override
  Future<Paged<Employee>> getAll({required int page, required int size}) async =>
      (await _api.getAll(page, size)).parsePage(EmployeeModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
