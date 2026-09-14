import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../data/models/employee_models.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

@injectable
class GetBranchEmployees {
  const GetBranchEmployees(this._repository);

  final EmployeeRepository _repository;

  Future<List<Employee>> call(int hotelId) async =>
      [...await _repository.byHotel(hotelId)]
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
}

@injectable
class SaveEmployee {
  const SaveEmployee(this._repository);

  final EmployeeRepository _repository;

  /// [id] rỗng → tạo nhân viên kèm tài khoản STAFF.
  Future<Employee> call(EmployeeRequest request, {int? id}) =>
      id == null ? _repository.create(request) : _repository.update(id, request);
}

@injectable
class DeleteEmployee {
  const DeleteEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}

/// Toàn bộ nhân viên hệ thống (quản trị).
@injectable
class GetEmployeesPage {
  const GetEmployeesPage(this._repository);

  final EmployeeRepository _repository;

  Future<Paged<Employee>> call({required int page, required int size}) =>
      _repository.getAll(page: page, size: size);
}
