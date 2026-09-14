import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.username,
    required this.role,
    this.active = true,
    this.createdAt,
  });

  final String id;
  final String username;
  final Role role;
  final bool active;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, username, role, active, createdAt];
}
