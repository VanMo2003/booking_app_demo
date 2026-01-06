import '../../data/models/request/employee_create_request.dart';
import '../../data/models/request/employee_update_request.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Employee> create(EmployeeCreateRequest req);
  Future<Employee> update(int id, EmployeeUpdateRequest req);
  Future<List<Employee>> getByHotel({required int hotelId});
  Future<void> delete(int id);
}
