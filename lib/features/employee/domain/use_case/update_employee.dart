import 'package:booking_app_mobile/features/employee/data/models/request/employee_update_request.dart';
import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import 'package:booking_app_mobile/features/employee/domain/repositories/employee_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<Employee> call(int id, EmployeeUpdateRequest request) async {
    return await repository.update(id, request);
  }
}
