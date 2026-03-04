import 'package:booking_app_mobile/features/auth/data/models/response/customer_response.dart';
import 'package:booking_app_mobile/features/auth/data/models/response/employee_response.dart';
import 'package:booking_app_mobile/features/auth/data/models/response/hotel_response.dart';

class Auth {
  static Auth? current;

  bool? authenticated;
  String? accessToken;
  String? refreshToken;
  String? role;
  String? accountId;
  HotelInfoResponse? hotel;
  CustomerResponse? customer;
  EmployeeResponse? employee;

  Auth(
      {this.authenticated,
      this.accessToken,
      this.refreshToken,
      this.role,
      this.accountId,
      this.employee,
      this.hotel,
      this.customer});

  static void clearCurrent() {
    current = null;
  }
}
