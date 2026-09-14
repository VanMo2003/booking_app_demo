import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/text/error_strings.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../customer/data/models/customer_models.dart';
import '../../../employee/data/models/employee_models.dart';
import '../../../hotel/data/models/hotel_models.dart';
import '../../../hotel_chain/data/models/hotel_chain_models.dart';
import '../../domain/entities/session.dart';

/// JSON `AuthenticationResponse` → [Session], và [Session] ↔ JSON lưu máy.
abstract final class SessionModel {
  static Session fromLogin(
    Json json, {
    required String fallbackUsername,
  }) {
    final role = Role.tryParse(json.strOrNull('role'));
    if (role == null) throw const AppException(ErrorStrings.badResponse);
    final customer = json.obj('customer');
    final employee = json.obj('employee');
    final chain = json.obj('hotelChain');
    return Session(
      role: role,
      username: JwtDecoder.subject(json.strOrNull('accessToken')) ?? fallbackUsername,
      accountId: json.strOrNull('accountId'),
      customer: customer == null ? null : CustomerModel.fromJson(customer),
      employee: employee == null ? null : EmployeeModel.fromJson(employee),
      hotels: json.listOf('hotels', HotelModel.fromJson),
      hotelChain: chain == null ? null : HotelChainModel.fromJson(chain),
      staffHotelId: employee?.intOrNull('hotelId'),
    );
  }

  static Json toJson(Session session) => {
        'role': session.role.value,
        'username': session.username,
        'accountId': session.accountId,
        'customer': session.customer == null
            ? null
            : CustomerModel.toJson(session.customer!),
        'employee': session.employee == null
            ? null
            : EmployeeModel.toJson(session.employee!),
        'hotels': session.hotels.map(HotelModel.toJson).toList(),
        'hotelChain': session.hotelChain == null
            ? null
            : HotelChainModel.toJson(session.hotelChain!),
        'staffHotelId': session.staffHotelId,
      };

  static Session? fromJson(Json json) {
    final role = Role.tryParse(json.strOrNull('role'));
    if (role == null) return null;
    final customer = json.obj('customer');
    final employee = json.obj('employee');
    final chain = json.obj('hotelChain');
    return Session(
      role: role,
      username: json.str('username'),
      accountId: json.strOrNull('accountId'),
      customer: customer == null ? null : CustomerModel.fromJson(customer),
      employee: employee == null ? null : EmployeeModel.fromJson(employee),
      hotels: json.listOf('hotels', HotelModel.fromJson),
      hotelChain: chain == null ? null : HotelChainModel.fromJson(chain),
      staffHotelId: json.intOrNull('staffHotelId'),
    );
  }
}
