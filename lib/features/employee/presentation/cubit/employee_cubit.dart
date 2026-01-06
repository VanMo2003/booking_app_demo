import 'package:booking_app_mobile/features/employee/data/models/request/employee_create_request.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_update_request.dart';
import 'package:booking_app_mobile/features/employee/domain/use_case/create_employee.dart';
import 'package:booking_app_mobile/features/employee/domain/use_case/delete_employee.dart';
import 'package:booking_app_mobile/features/employee/domain/use_case/get_employee_by_hotel.dart';
import 'package:booking_app_mobile/features/employee/domain/use_case/update_employee.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/employee.dart';

part 'employee_state.dart';
part 'employee_cubit.freezed.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final GetEmployeeByHotel getEmployeeByHotel;
  final CreateEmployee createEmployee;
  final UpdateEmployee updateEmployee;
  final DeleteEmployee deleteEmployee;

  EmployeeCubit({
    required this.getEmployeeByHotel,
    required this.createEmployee,
    required this.updateEmployee,
    required this.deleteEmployee,
  }) : super(EmployeeState());

  Future<void> fetchEmployees({required int hotelId}) async {
    try {
      emit(state.copyWith(status: EmployeeStatus.loading));
      final List<Employee> employees = await getEmployeeByHotel.call(hotelId: hotelId);
      emit(state.copyWith(status: EmployeeStatus.success, employees: employees));
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  Future<void> addEmployee(EmployeeCreateRequest req) async {
    try {
      emit(state.copyWith(status: EmployeeStatus.loading));
      var employeeRes = await createEmployee.call(req);
      var employees = state.employees?.toList() ?? [];
      employees.add(employeeRes);
      emit(state.copyWith(status: EmployeeStatus.success, employees: employees));
    } on AppException catch (e) {
      emit(state.copyWith(status: EmployeeStatus.success, errorMessage: e.message));
    }
  }

  Future<void> editEmployee(int id, EmployeeUpdateRequest req) async {
    try {
      emit(state.copyWith(status: EmployeeStatus.loading));
      var employeeRes = await updateEmployee.call(id, req);
      var employees = state.employees?.map((pos) {
        if (pos.id == employeeRes.id) {
          pos = employeeRes;
          return pos;
        }
        return pos;
      }).toList();
      emit(state.copyWith(status: EmployeeStatus.success, employees: employees));
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  Future<void> removeEmployee(int id) async {
    try {
      emit(state.copyWith(status: EmployeeStatus.loading));

      await deleteEmployee.call(id);
      var employees = state.employees?.toList();
      employees?.removeWhere((position) => position.id == id);
      emit(state.copyWith(status: EmployeeStatus.success, employees: employees));
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }
}
