import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/employee.dart';

/// JSON `EmployeeResponse` ↔ [Employee].
abstract final class EmployeeModel {
  static Employee fromJson(Json json) => Employee(
        id: json.integer('id'),
        fullName: json.str('fullName'),
        accountId: json.strOrNull('accountId'),
        pathImage: json.strOrNull('pathImage'),
        phoneNumber: json.str('phoneNumber'),
        gender: json.str('gender'),
        dateOfBirth: json.date('dateOfBirth'),
        hometown: json.str('hometown'),
        salary: json.decimal('salary'),
        hotelId: json.intOrNull('hotelId'),
        hotelName: json.strOrNull('hotelName'),
        positionName: json.str('positionName'),
      );

  static Json toJson(Employee employee) => {
        'id': employee.id,
        'fullName': employee.fullName,
        'accountId': employee.accountId,
        'pathImage': employee.pathImage,
        'phoneNumber': employee.phoneNumber,
        'gender': employee.gender,
        'dateOfBirth': employee.dateOfBirth == null
            ? null
            : Fmt.apiDate(employee.dateOfBirth!),
        'hometown': employee.hometown,
        'salary': employee.salary,
        'hotelId': employee.hotelId,
        'hotelName': employee.hotelName,
        'positionName': employee.positionName,
      };
}

class EmployeeRequest {
  const EmployeeRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.hometown,
    required this.salary,
    required this.positionId,
    this.dateOfBirth,
    this.pathImage,
    this.username,
    this.password,
    this.hotelId,
  });

  final String fullName;
  final String phoneNumber;
  final String gender;
  final String hometown;
  final double salary;
  final int positionId;
  final DateTime? dateOfBirth;
  final String? pathImage;

  /// Chỉ khi tạo mới — BE tạo luôn tài khoản STAFF.
  final String? username;
  final String? password;
  final int? hotelId;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'hometown': hometown,
        'salary': salary.round(),
        'positionId': positionId,
        'pathImage': pathImage ?? '',
        if (dateOfBirth != null) 'dateOfBirth': Fmt.apiDate(dateOfBirth!),
        if (username != null) 'username': username,
        if (password != null) 'password': password,
        if (hotelId != null) 'hotelId': hotelId,
      };
}
