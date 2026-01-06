import 'package:booking_app_mobile/features/employee/data/models/request/employee_create_request.dart';
import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import 'package:booking_app_mobile/features/employee/domain/repositories/employee_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  Future<Employee> call(EmployeeCreateRequest request) async {
    return await repository.create(request);
  }
}
