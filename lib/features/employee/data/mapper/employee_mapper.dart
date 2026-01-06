import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import '../../../auth/data/models/response/employee_response.dart';

class EmployeeMapper {
  EmployeeMapper._();

  static Employee toEntity(EmployeeResponse dto) {
    return Employee(
      id: dto.id ?? 0,
      username: dto.username ?? "",
      pathImage: dto.pathImage ?? "",
      accountId: dto.accountId ?? '',
      fullName: dto.fullName ?? '',
      phoneNumber: dto.phoneNumber ?? '',
      gender: dto.gender ?? '',
      dateOfBirth: dto.dateOfBirth ?? '',
      hometown: dto.hometown ?? '',
      positionName: dto.positionName ?? "",
      salary: dto.salary ?? 0,
    );
  }

  static EmployeeResponse toResponse(Employee entity) {
    return EmployeeResponse(
      id: entity.id,
      username: entity.username,
      pathImage: entity.pathImage,
      accountId: entity.accountId,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      hometown: entity.hometown,
      salary: entity.salary,
    );
  }
}
