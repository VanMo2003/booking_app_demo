import 'package:injectable/injectable.dart';

import '../repositories/employee_repository.dart';

@injectable
class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<void> call(int id) async {
    return await repository.delete(id);
  }
}
