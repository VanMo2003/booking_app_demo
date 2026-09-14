import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../employee/domain/entities/employee.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel_chain/domain/entities/hotel_chain.dart';

/// Người đang đăng nhập. Token nằm riêng trong `TokenStorage`; ở đây chỉ là
/// hồ sơ theo vai trò mà `/auth/login` trả về.
class Session extends Equatable {
  const Session({
    required this.role,
    required this.username,
    this.accountId,
    this.customer,
    this.employee,
    this.hotels = const [],
    this.hotelChain,
    this.staffHotelId,
  });

  final Role role;
  final String username;

  /// Chỉ có khi tài khoản chưa có hồ sơ theo vai trò.
  final String? accountId;

  /// CUSTOMER
  final Customer? customer;

  /// STAFF
  final Employee? employee;

  /// HOTEL_MANAGER — các cơ sở được giao.
  final List<Hotel> hotels;

  /// HOTEL_OWNER
  final HotelChain? hotelChain;

  /// Cơ sở làm việc của nhân viên (dò được sau khi đăng nhập).
  final int? staffHotelId;

  String get displayName =>
      customer?.fullName ?? employee?.fullName ?? hotelChain?.name ?? username;

  String? get resolvedAccountId =>
      accountId ??
      customer?.accountId ??
      employee?.accountId ??
      hotelChain?.accountId ??
      (hotels.isNotEmpty ? hotels.first.accountId : null);

  bool get needsCustomerProfile => role == Role.customer && customer == null;

  Session copyWith({
    String? accountId,
    Customer? customer,
    Employee? employee,
    List<Hotel>? hotels,
    HotelChain? hotelChain,
    int? staffHotelId,
    bool clearChain = false,
  }) =>
      Session(
        role: role,
        username: username,
        accountId: accountId ?? this.accountId,
        customer: customer ?? this.customer,
        employee: employee ?? this.employee,
        hotels: hotels ?? this.hotels,
        hotelChain: clearChain ? null : hotelChain ?? this.hotelChain,
        staffHotelId: staffHotelId ?? this.staffHotelId,
      );

  @override
  List<Object?> get props => [
        role,
        username,
        accountId,
        customer,
        employee,
        hotels,
        hotelChain,
        staffHotelId,
      ];
}
