import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import 'package:injectable/injectable.dart';

import '../repositories/employee_repository.dart';


@injectable
class GetEmployeeByHotel {
  final EmployeeRepository repository;

  GetEmployeeByHotel(this.repository);

  Future<List<Employee>> call({required int hotelId}) async {
    return await repository.getByHotel(hotelId: hotelId);
  }
}
