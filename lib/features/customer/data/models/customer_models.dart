import '../../../../core/network/json_reader.dart';
import '../../domain/entities/customer.dart';

/// JSON `CustomerResponse` ↔ [Customer].
abstract final class CustomerModel {
  static Customer fromJson(Json json) => Customer(
        id: json.integer('id'),
        fullName: json.str('fullName'),
        phoneNumber: json.str('phoneNumber'),
        pathImage: json.strOrNull('pathImage'),
        accountId: json.strOrNull('accountId'),
        username: json.strOrNull('username'),
        gender: json.str('gender'),
        hometown: json.str('hometown'),
      );

  static Json toJson(Customer customer) => {
        'id': customer.id,
        'fullName': customer.fullName,
        'phoneNumber': customer.phoneNumber,
        'pathImage': customer.pathImage,
        'accountId': customer.accountId,
        'username': customer.username,
        'gender': customer.gender,
        'hometown': customer.hometown,
      };
}

class CustomerRequest {
  const CustomerRequest({
    required this.fullName,
    required this.phoneNumber,
    this.gender = '',
    this.hometown = '',
    this.pathImage,
    this.accountId,
  });

  final String fullName;
  final String phoneNumber;
  final String gender;
  final String hometown;
  final String? pathImage;

  /// Bỏ trống khi nhân viên tạo hồ sơ khách vãng lai.
  final String? accountId;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'hometown': hometown,
        'pathImage': pathImage ?? '',
        if (accountId != null && accountId!.isNotEmpty) 'accountId': accountId,
      };
}
