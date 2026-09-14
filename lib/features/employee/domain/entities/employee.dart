import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.fullName,
    this.accountId,
    this.pathImage,
    this.phoneNumber = '',
    this.gender = '',
    this.dateOfBirth,
    this.hometown = '',
    this.salary = 0,
    this.hotelId,
    this.hotelName,
    this.positionName = '',
  });

  final int id;
  final String fullName;
  final String? accountId;
  final String? pathImage;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;
  final String hometown;
  final double salary;

  /// BE hiện chưa trả `hotelId` cho nhân viên; FE tự dò cơ sở khi thiếu.
  final int? hotelId;
  final String? hotelName;
  final String positionName;

  @override
  List<Object?> get props => [
        id,
        fullName,
        accountId,
        pathImage,
        phoneNumber,
        gender,
        dateOfBirth,
        hometown,
        salary,
        hotelId,
        hotelName,
        positionName,
      ];
}
