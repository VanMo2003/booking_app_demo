import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/account.dart';

/// JSON `AccountResponse` ↔ [Account].
abstract final class AccountModel {
  static Account fromJson(Json json) => Account(
        id: json.str('id'),
        username: json.str('username'),
        role: Role.tryParse(json.strOrNull('role')) ?? Role.customer,
        active: json.flag('status', true),
        createdAt: json.dateTime('onCreate'),
      );
}

class AccountCreateRequest {
  const AccountCreateRequest({
    required this.username,
    required this.password,
    required this.role,
  });

  final String username;
  final String password;
  final Role role;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role.value,
        'status': true,
      };
}

/// Không gửi mật khẩu: BE hiện lưu mật khẩu cập nhật mà không mã hoá.
class AccountUpdateRequest {
  const AccountUpdateRequest({this.role, this.active});

  final Role? role;
  final bool? active;

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role!.value,
        if (active != null) 'status': active,
      };
}
