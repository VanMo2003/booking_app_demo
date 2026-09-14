import '../../../../core/network/paged.dart';
import '../../data/models/employee_models.dart';
import '../entities/employee.dart';

abstract interface class EmployeeRepository {
  Future<Employee> create(EmployeeRequest request);

  Future<Employee> update(int id, EmployeeRequest request);

  Future<Employee> getById(int id);

  Future<List<Employee>> byHotel(int hotelId);

  Future<Paged<Employee>> getAll({required int page, required int size});

  Future<void> delete(int id);
}
