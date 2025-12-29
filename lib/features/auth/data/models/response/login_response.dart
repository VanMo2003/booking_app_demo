import 'package:booking_app_mobile/features/auth/data/models/response/customer_response.dart';
import 'package:booking_app_mobile/features/auth/data/models/response/employee_response.dart';
import 'package:booking_app_mobile/features/auth/data/models/response/hotel_response.dart';

class LoginResponse {
  bool? authenticated;
  String? accessToken;
  String? refreshToken;
  String? role;
  HotelResponse? hotel;
  CustomerResponse? customer;
  EmployeeResponse? employee;

  LoginResponse(
      {this.authenticated,
      this.accessToken,
      this.refreshToken,
      this.role,
      this.employee,
      this.hotel,
      this.customer});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    authenticated = json['authenticated'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    role = json['role'];
    hotel =
        json['hotel'] != null ? HotelResponse.fromJson(json['hotel']) : null;
    customer = json['customer'] != null
        ? CustomerResponse.fromJson(json['customer'])
        : null;
    employee = json['employee'] != null
        ? EmployeeResponse.fromJson(json['employee'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['authenticated'] = authenticated;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['role'] = role;
    if (employee != null) {
      data['employee'] = employee!.toJson();
    }
    if (hotel != null) {
      data['hotel'] = hotel!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}
