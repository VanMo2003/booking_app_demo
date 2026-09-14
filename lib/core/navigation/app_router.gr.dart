// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i50;
import 'package:booking_app_mobile/features/admin/presentation/accounts_screen.dart'
    as _i2;
import 'package:booking_app_mobile/features/admin/presentation/admin_overview_screen.dart'
    as _i3;
import 'package:booking_app_mobile/features/admin/presentation/catalog_screen.dart'
    as _i14;
import 'package:booking_app_mobile/features/admin/presentation/system_data_screen.dart'
    as _i46;
import 'package:booking_app_mobile/features/amenity/presentation/amenities_screen.dart'
    as _i5;
import 'package:booking_app_mobile/features/auth/presentation/login/login_screen.dart'
    as _i28;
import 'package:booking_app_mobile/features/auth/presentation/profile_setup/profile_setup_screen.dart'
    as _i36;
import 'package:booking_app_mobile/features/auth/presentation/register/register_screen.dart'
    as _i37;
import 'package:booking_app_mobile/features/booking/presentation/create/booking_create_screen.dart'
    as _i6;
import 'package:booking_app_mobile/features/booking/presentation/desk/desk_screen.dart'
    as _i22;
import 'package:booking_app_mobile/features/booking/presentation/detail/booking_detail_screen.dart'
    as _i7;
import 'package:booking_app_mobile/features/booking/presentation/edit/booking_edit_screen.dart'
    as _i8;
import 'package:booking_app_mobile/features/booking/presentation/my_bookings/my_bookings_screen.dart'
    as _i30;
import 'package:booking_app_mobile/features/booking/presentation/walk_in/walk_in_booking_screen.dart'
    as _i47;
import 'package:booking_app_mobile/features/customer/domain/entities/customer.dart'
    as _i53;
import 'package:booking_app_mobile/features/customer/presentation/account/account_screen.dart'
    as _i1;
import 'package:booking_app_mobile/features/customer/presentation/branch/branch_customers_screen.dart'
    as _i9;
import 'package:booking_app_mobile/features/customer/presentation/branch/customer_detail_screen.dart'
    as _i19;
import 'package:booking_app_mobile/features/customer/presentation/profile/profile_edit_screen.dart'
    as _i35;
import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart'
    as _i54;
import 'package:booking_app_mobile/features/employee/presentation/employee_form_screen.dart'
    as _i23;
import 'package:booking_app_mobile/features/employee/presentation/employees_screen.dart'
    as _i24;
import 'package:booking_app_mobile/features/favorite/presentation/favorites_screen.dart'
    as _i26;
import 'package:booking_app_mobile/features/feedback/presentation/review_screen.dart'
    as _i38;
import 'package:booking_app_mobile/features/hotel/presentation/branch/branch_info_screen.dart'
    as _i11;
import 'package:booking_app_mobile/features/hotel/presentation/detail/hotel_detail_screen.dart'
    as _i27;
import 'package:booking_app_mobile/features/hotel/presentation/explore/explore_screen.dart'
    as _i25;
import 'package:booking_app_mobile/features/hotel/presentation/search/search_results_screen.dart'
    as _i43;
import 'package:booking_app_mobile/features/hotel_chain/presentation/branch_form_screen.dart'
    as _i10;
import 'package:booking_app_mobile/features/hotel_chain/presentation/chain_branches_screen.dart'
    as _i15;
import 'package:booking_app_mobile/features/hotel_chain/presentation/chain_info_screen.dart'
    as _i16;
import 'package:booking_app_mobile/features/hotel_chain/presentation/chain_overview_screen.dart'
    as _i17;
import 'package:booking_app_mobile/features/hotel_chain/presentation/create_chain_screen.dart'
    as _i18;
import 'package:booking_app_mobile/features/hotel_chain/presentation/managers_screen.dart'
    as _i29;
import 'package:booking_app_mobile/features/payment/presentation/payment_webview_screen.dart'
    as _i33;
import 'package:booking_app_mobile/features/payroll/presentation/payroll_screen.dart'
    as _i34;
import 'package:booking_app_mobile/features/report/presentation/dashboard/dashboard_screen.dart'
    as _i21;
import 'package:booking_app_mobile/features/report/presentation/reports/report_screens.dart'
    as _i13;
import 'package:booking_app_mobile/features/room/domain/entities/room.dart'
    as _i55;
import 'package:booking_app_mobile/features/room/presentation/detail/room_detail_screen.dart'
    as _i39;
import 'package:booking_app_mobile/features/room/presentation/manage/room_form_screen.dart'
    as _i40;
import 'package:booking_app_mobile/features/room/presentation/manage/room_manage_detail_screen.dart'
    as _i41;
import 'package:booking_app_mobile/features/room/presentation/manage/rooms_manage_screen.dart'
    as _i42;
import 'package:booking_app_mobile/features/service/presentation/services_screen.dart'
    as _i44;
import 'package:booking_app_mobile/features/shell/presentation/admin_shell_screen.dart'
    as _i4;
import 'package:booking_app_mobile/features/shell/presentation/branch_picker_screen.dart'
    as _i12;
import 'package:booking_app_mobile/features/shell/presentation/customer_shell_screen.dart'
    as _i20;
import 'package:booking_app_mobile/features/shell/presentation/owner_more_screen.dart'
    as _i31;
import 'package:booking_app_mobile/features/shell/presentation/owner_shell_screen.dart'
    as _i32;
import 'package:booking_app_mobile/features/shell/presentation/workspace_more_screen.dart'
    as _i48;
import 'package:booking_app_mobile/features/shell/presentation/workspace_shell_screen.dart'
    as _i49;
import 'package:booking_app_mobile/features/splash/presentation/splash_screen.dart'
    as _i45;
import 'package:collection/collection.dart' as _i52;
import 'package:flutter/material.dart' as _i51;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i50.PageRouteInfo<void> {
  const AccountRoute({List<_i50.PageRouteInfo>? children})
      : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountsScreen]
class AccountsRoute extends _i50.PageRouteInfo<void> {
  const AccountsRoute({List<_i50.PageRouteInfo>? children})
      : super(AccountsRoute.name, initialChildren: children);

  static const String name = 'AccountsRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountsScreen();
    },
  );
}

/// generated route for
/// [_i3.AdminOverviewScreen]
class AdminOverviewRoute extends _i50.PageRouteInfo<void> {
  const AdminOverviewRoute({List<_i50.PageRouteInfo>? children})
      : super(AdminOverviewRoute.name, initialChildren: children);

  static const String name = 'AdminOverviewRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdminOverviewScreen();
    },
  );
}

/// generated route for
/// [_i4.AdminShellScreen]
class AdminShellRoute extends _i50.PageRouteInfo<void> {
  const AdminShellRoute({List<_i50.PageRouteInfo>? children})
      : super(AdminShellRoute.name, initialChildren: children);

  static const String name = 'AdminShellRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i4.AdminShellScreen();
    },
  );
}

/// generated route for
/// [_i5.AmenitiesScreen]
class AmenitiesRoute extends _i50.PageRouteInfo<AmenitiesRouteArgs> {
  AmenitiesRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          AmenitiesRoute.name,
          args: AmenitiesRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'AmenitiesRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AmenitiesRouteArgs>();
      return _i5.AmenitiesScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class AmenitiesRouteArgs {
  const AmenitiesRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'AmenitiesRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AmenitiesRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i6.BookingCreateScreen]
class BookingCreateRoute extends _i50.PageRouteInfo<BookingCreateRouteArgs> {
  BookingCreateRoute({
    _i51.Key? key,
    required int hotelId,
    required DateTime checkin,
    required DateTime checkout,
    List<int> preselectedRoomIds = const [],
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BookingCreateRoute.name,
          args: BookingCreateRouteArgs(
            key: key,
            hotelId: hotelId,
            checkin: checkin,
            checkout: checkout,
            preselectedRoomIds: preselectedRoomIds,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingCreateRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingCreateRouteArgs>();
      return _i6.BookingCreateScreen(
        key: args.key,
        hotelId: args.hotelId,
        checkin: args.checkin,
        checkout: args.checkout,
        preselectedRoomIds: args.preselectedRoomIds,
      );
    },
  );
}

class BookingCreateRouteArgs {
  const BookingCreateRouteArgs({
    this.key,
    required this.hotelId,
    required this.checkin,
    required this.checkout,
    this.preselectedRoomIds = const [],
  });

  final _i51.Key? key;

  final int hotelId;

  final DateTime checkin;

  final DateTime checkout;

  final List<int> preselectedRoomIds;

  @override
  String toString() {
    return 'BookingCreateRouteArgs{key: $key, hotelId: $hotelId, checkin: $checkin, checkout: $checkout, preselectedRoomIds: $preselectedRoomIds}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingCreateRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        checkin == other.checkin &&
        checkout == other.checkout &&
        const _i52.ListEquality().equals(
          preselectedRoomIds,
          other.preselectedRoomIds,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      hotelId.hashCode ^
      checkin.hashCode ^
      checkout.hashCode ^
      const _i52.ListEquality().hash(preselectedRoomIds);
}

/// generated route for
/// [_i7.BookingDetailScreen]
class BookingDetailRoute extends _i50.PageRouteInfo<BookingDetailRouteArgs> {
  BookingDetailRoute({
    _i51.Key? key,
    required int bookingId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BookingDetailRoute.name,
          args: BookingDetailRouteArgs(key: key, bookingId: bookingId),
          initialChildren: children,
        );

  static const String name = 'BookingDetailRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingDetailRouteArgs>();
      return _i7.BookingDetailScreen(key: args.key, bookingId: args.bookingId);
    },
  );
}

class BookingDetailRouteArgs {
  const BookingDetailRouteArgs({this.key, required this.bookingId});

  final _i51.Key? key;

  final int bookingId;

  @override
  String toString() {
    return 'BookingDetailRouteArgs{key: $key, bookingId: $bookingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingDetailRouteArgs) return false;
    return key == other.key && bookingId == other.bookingId;
  }

  @override
  int get hashCode => key.hashCode ^ bookingId.hashCode;
}

/// generated route for
/// [_i8.BookingEditScreen]
class BookingEditRoute extends _i50.PageRouteInfo<BookingEditRouteArgs> {
  BookingEditRoute({
    _i51.Key? key,
    required int bookingId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BookingEditRoute.name,
          args: BookingEditRouteArgs(key: key, bookingId: bookingId),
          initialChildren: children,
        );

  static const String name = 'BookingEditRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingEditRouteArgs>();
      return _i8.BookingEditScreen(key: args.key, bookingId: args.bookingId);
    },
  );
}

class BookingEditRouteArgs {
  const BookingEditRouteArgs({this.key, required this.bookingId});

  final _i51.Key? key;

  final int bookingId;

  @override
  String toString() {
    return 'BookingEditRouteArgs{key: $key, bookingId: $bookingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingEditRouteArgs) return false;
    return key == other.key && bookingId == other.bookingId;
  }

  @override
  int get hashCode => key.hashCode ^ bookingId.hashCode;
}

/// generated route for
/// [_i9.BranchCustomersScreen]
class BranchCustomersRoute extends _i50.PageRouteInfo<void> {
  const BranchCustomersRoute({List<_i50.PageRouteInfo>? children})
      : super(BranchCustomersRoute.name, initialChildren: children);

  static const String name = 'BranchCustomersRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i9.BranchCustomersScreen();
    },
  );
}

/// generated route for
/// [_i10.BranchFormScreen]
class BranchFormRoute extends _i50.PageRouteInfo<BranchFormRouteArgs> {
  BranchFormRoute({
    _i51.Key? key,
    required int chainId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BranchFormRoute.name,
          args: BranchFormRouteArgs(key: key, chainId: chainId),
          initialChildren: children,
        );

  static const String name = 'BranchFormRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BranchFormRouteArgs>();
      return _i10.BranchFormScreen(key: args.key, chainId: args.chainId);
    },
  );
}

class BranchFormRouteArgs {
  const BranchFormRouteArgs({this.key, required this.chainId});

  final _i51.Key? key;

  final int chainId;

  @override
  String toString() {
    return 'BranchFormRouteArgs{key: $key, chainId: $chainId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BranchFormRouteArgs) return false;
    return key == other.key && chainId == other.chainId;
  }

  @override
  int get hashCode => key.hashCode ^ chainId.hashCode;
}

/// generated route for
/// [_i11.BranchInfoScreen]
class BranchInfoRoute extends _i50.PageRouteInfo<BranchInfoRouteArgs> {
  BranchInfoRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BranchInfoRoute.name,
          args: BranchInfoRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'BranchInfoRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BranchInfoRouteArgs>();
      return _i11.BranchInfoScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class BranchInfoRouteArgs {
  const BranchInfoRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'BranchInfoRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BranchInfoRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i12.BranchPickerScreen]
class BranchPickerRoute extends _i50.PageRouteInfo<void> {
  const BranchPickerRoute({List<_i50.PageRouteInfo>? children})
      : super(BranchPickerRoute.name, initialChildren: children);

  static const String name = 'BranchPickerRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i12.BranchPickerScreen();
    },
  );
}

/// generated route for
/// [_i13.BranchReportsScreen]
class BranchReportsRoute extends _i50.PageRouteInfo<void> {
  const BranchReportsRoute({List<_i50.PageRouteInfo>? children})
      : super(BranchReportsRoute.name, initialChildren: children);

  static const String name = 'BranchReportsRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i13.BranchReportsScreen();
    },
  );
}

/// generated route for
/// [_i14.CatalogScreen]
class CatalogRoute extends _i50.PageRouteInfo<void> {
  const CatalogRoute({List<_i50.PageRouteInfo>? children})
      : super(CatalogRoute.name, initialChildren: children);

  static const String name = 'CatalogRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i14.CatalogScreen();
    },
  );
}

/// generated route for
/// [_i15.ChainBranchesScreen]
class ChainBranchesRoute extends _i50.PageRouteInfo<void> {
  const ChainBranchesRoute({List<_i50.PageRouteInfo>? children})
      : super(ChainBranchesRoute.name, initialChildren: children);

  static const String name = 'ChainBranchesRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i15.ChainBranchesScreen();
    },
  );
}

/// generated route for
/// [_i16.ChainInfoScreen]
class ChainInfoRoute extends _i50.PageRouteInfo<ChainInfoRouteArgs> {
  ChainInfoRoute({
    _i51.Key? key,
    required int chainId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ChainInfoRoute.name,
          args: ChainInfoRouteArgs(key: key, chainId: chainId),
          initialChildren: children,
        );

  static const String name = 'ChainInfoRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChainInfoRouteArgs>();
      return _i16.ChainInfoScreen(key: args.key, chainId: args.chainId);
    },
  );
}

class ChainInfoRouteArgs {
  const ChainInfoRouteArgs({this.key, required this.chainId});

  final _i51.Key? key;

  final int chainId;

  @override
  String toString() {
    return 'ChainInfoRouteArgs{key: $key, chainId: $chainId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChainInfoRouteArgs) return false;
    return key == other.key && chainId == other.chainId;
  }

  @override
  int get hashCode => key.hashCode ^ chainId.hashCode;
}

/// generated route for
/// [_i17.ChainOverviewScreen]
class ChainOverviewRoute extends _i50.PageRouteInfo<void> {
  const ChainOverviewRoute({List<_i50.PageRouteInfo>? children})
      : super(ChainOverviewRoute.name, initialChildren: children);

  static const String name = 'ChainOverviewRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i17.ChainOverviewScreen();
    },
  );
}

/// generated route for
/// [_i13.ChainReportsScreen]
class ChainReportsRoute extends _i50.PageRouteInfo<void> {
  const ChainReportsRoute({List<_i50.PageRouteInfo>? children})
      : super(ChainReportsRoute.name, initialChildren: children);

  static const String name = 'ChainReportsRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i13.ChainReportsScreen();
    },
  );
}

/// generated route for
/// [_i18.CreateChainScreen]
class CreateChainRoute extends _i50.PageRouteInfo<void> {
  const CreateChainRoute({List<_i50.PageRouteInfo>? children})
      : super(CreateChainRoute.name, initialChildren: children);

  static const String name = 'CreateChainRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i18.CreateChainScreen();
    },
  );
}

/// generated route for
/// [_i19.CustomerDetailScreen]
class CustomerDetailRoute extends _i50.PageRouteInfo<CustomerDetailRouteArgs> {
  CustomerDetailRoute({
    _i51.Key? key,
    required int hotelId,
    required _i53.Customer customer,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          CustomerDetailRoute.name,
          args: CustomerDetailRouteArgs(
            key: key,
            hotelId: hotelId,
            customer: customer,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomerDetailRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailRouteArgs>();
      return _i19.CustomerDetailScreen(
        key: args.key,
        hotelId: args.hotelId,
        customer: args.customer,
      );
    },
  );
}

class CustomerDetailRouteArgs {
  const CustomerDetailRouteArgs({
    this.key,
    required this.hotelId,
    required this.customer,
  });

  final _i51.Key? key;

  final int hotelId;

  final _i53.Customer customer;

  @override
  String toString() {
    return 'CustomerDetailRouteArgs{key: $key, hotelId: $hotelId, customer: $customer}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDetailRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        customer == other.customer;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode ^ customer.hashCode;
}

/// generated route for
/// [_i9.CustomerDirectoryScreen]
class CustomerDirectoryRoute
    extends _i50.PageRouteInfo<CustomerDirectoryRouteArgs> {
  CustomerDirectoryRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          CustomerDirectoryRoute.name,
          args: CustomerDirectoryRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'CustomerDirectoryRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDirectoryRouteArgs>();
      return _i9.CustomerDirectoryScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class CustomerDirectoryRouteArgs {
  const CustomerDirectoryRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'CustomerDirectoryRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDirectoryRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i20.CustomerShellScreen]
class CustomerShellRoute extends _i50.PageRouteInfo<void> {
  const CustomerShellRoute({List<_i50.PageRouteInfo>? children})
      : super(CustomerShellRoute.name, initialChildren: children);

  static const String name = 'CustomerShellRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i20.CustomerShellScreen();
    },
  );
}

/// generated route for
/// [_i21.DashboardScreen]
class DashboardRoute extends _i50.PageRouteInfo<void> {
  const DashboardRoute({List<_i50.PageRouteInfo>? children})
      : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i21.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i22.DeskScreen]
class DeskRoute extends _i50.PageRouteInfo<void> {
  const DeskRoute({List<_i50.PageRouteInfo>? children})
      : super(DeskRoute.name, initialChildren: children);

  static const String name = 'DeskRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i22.DeskScreen();
    },
  );
}

/// generated route for
/// [_i23.EmployeeFormScreen]
class EmployeeFormRoute extends _i50.PageRouteInfo<EmployeeFormRouteArgs> {
  EmployeeFormRoute({
    _i51.Key? key,
    required int hotelId,
    _i54.Employee? employee,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          EmployeeFormRoute.name,
          args: EmployeeFormRouteArgs(
            key: key,
            hotelId: hotelId,
            employee: employee,
          ),
          initialChildren: children,
        );

  static const String name = 'EmployeeFormRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployeeFormRouteArgs>();
      return _i23.EmployeeFormScreen(
        key: args.key,
        hotelId: args.hotelId,
        employee: args.employee,
      );
    },
  );
}

class EmployeeFormRouteArgs {
  const EmployeeFormRouteArgs({this.key, required this.hotelId, this.employee});

  final _i51.Key? key;

  final int hotelId;

  final _i54.Employee? employee;

  @override
  String toString() {
    return 'EmployeeFormRouteArgs{key: $key, hotelId: $hotelId, employee: $employee}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmployeeFormRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        employee == other.employee;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode ^ employee.hashCode;
}

/// generated route for
/// [_i24.EmployeesScreen]
class EmployeesRoute extends _i50.PageRouteInfo<EmployeesRouteArgs> {
  EmployeesRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          EmployeesRoute.name,
          args: EmployeesRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'EmployeesRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployeesRouteArgs>();
      return _i24.EmployeesScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class EmployeesRouteArgs {
  const EmployeesRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'EmployeesRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmployeesRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i25.ExploreScreen]
class ExploreRoute extends _i50.PageRouteInfo<void> {
  const ExploreRoute({List<_i50.PageRouteInfo>? children})
      : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i25.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i26.FavoritesScreen]
class FavoritesRoute extends _i50.PageRouteInfo<void> {
  const FavoritesRoute({List<_i50.PageRouteInfo>? children})
      : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i26.FavoritesScreen();
    },
  );
}

/// generated route for
/// [_i27.HotelDetailScreen]
class HotelDetailRoute extends _i50.PageRouteInfo<HotelDetailRouteArgs> {
  HotelDetailRoute({
    _i51.Key? key,
    required int hotelId,
    DateTime? checkin,
    DateTime? checkout,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          HotelDetailRoute.name,
          args: HotelDetailRouteArgs(
            key: key,
            hotelId: hotelId,
            checkin: checkin,
            checkout: checkout,
          ),
          initialChildren: children,
        );

  static const String name = 'HotelDetailRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HotelDetailRouteArgs>();
      return _i27.HotelDetailScreen(
        key: args.key,
        hotelId: args.hotelId,
        checkin: args.checkin,
        checkout: args.checkout,
      );
    },
  );
}

class HotelDetailRouteArgs {
  const HotelDetailRouteArgs({
    this.key,
    required this.hotelId,
    this.checkin,
    this.checkout,
  });

  final _i51.Key? key;

  final int hotelId;

  final DateTime? checkin;

  final DateTime? checkout;

  @override
  String toString() {
    return 'HotelDetailRouteArgs{key: $key, hotelId: $hotelId, checkin: $checkin, checkout: $checkout}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HotelDetailRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        checkin == other.checkin &&
        checkout == other.checkout;
  }

  @override
  int get hashCode =>
      key.hashCode ^ hotelId.hashCode ^ checkin.hashCode ^ checkout.hashCode;
}

/// generated route for
/// [_i28.LoginScreen]
class LoginRoute extends _i50.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i51.Key? key,
    bool returnResult = false,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(key: key, returnResult: returnResult),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i28.LoginScreen(key: args.key, returnResult: args.returnResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.returnResult = false});

  final _i51.Key? key;

  final bool returnResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, returnResult: $returnResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && returnResult == other.returnResult;
  }

  @override
  int get hashCode => key.hashCode ^ returnResult.hashCode;
}

/// generated route for
/// [_i29.ManagersScreen]
class ManagersRoute extends _i50.PageRouteInfo<ManagersRouteArgs> {
  ManagersRoute({
    _i51.Key? key,
    required int chainId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ManagersRoute.name,
          args: ManagersRouteArgs(key: key, chainId: chainId),
          initialChildren: children,
        );

  static const String name = 'ManagersRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ManagersRouteArgs>();
      return _i29.ManagersScreen(key: args.key, chainId: args.chainId);
    },
  );
}

class ManagersRouteArgs {
  const ManagersRouteArgs({this.key, required this.chainId});

  final _i51.Key? key;

  final int chainId;

  @override
  String toString() {
    return 'ManagersRouteArgs{key: $key, chainId: $chainId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ManagersRouteArgs) return false;
    return key == other.key && chainId == other.chainId;
  }

  @override
  int get hashCode => key.hashCode ^ chainId.hashCode;
}

/// generated route for
/// [_i30.MyBookingsScreen]
class MyBookingsRoute extends _i50.PageRouteInfo<void> {
  const MyBookingsRoute({List<_i50.PageRouteInfo>? children})
      : super(MyBookingsRoute.name, initialChildren: children);

  static const String name = 'MyBookingsRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i30.MyBookingsScreen();
    },
  );
}

/// generated route for
/// [_i31.OwnerMoreScreen]
class OwnerMoreRoute extends _i50.PageRouteInfo<void> {
  const OwnerMoreRoute({List<_i50.PageRouteInfo>? children})
      : super(OwnerMoreRoute.name, initialChildren: children);

  static const String name = 'OwnerMoreRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i31.OwnerMoreScreen();
    },
  );
}

/// generated route for
/// [_i32.OwnerShellScreen]
class OwnerShellRoute extends _i50.PageRouteInfo<void> {
  const OwnerShellRoute({List<_i50.PageRouteInfo>? children})
      : super(OwnerShellRoute.name, initialChildren: children);

  static const String name = 'OwnerShellRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i32.OwnerShellScreen();
    },
  );
}

/// generated route for
/// [_i33.PaymentWebViewScreen]
class PaymentWebViewRoute extends _i50.PageRouteInfo<PaymentWebViewRouteArgs> {
  PaymentWebViewRoute({
    _i51.Key? key,
    required String paymentUrl,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          PaymentWebViewRoute.name,
          args: PaymentWebViewRouteArgs(key: key, paymentUrl: paymentUrl),
          initialChildren: children,
        );

  static const String name = 'PaymentWebViewRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentWebViewRouteArgs>();
      return _i33.PaymentWebViewScreen(
        key: args.key,
        paymentUrl: args.paymentUrl,
      );
    },
  );
}

class PaymentWebViewRouteArgs {
  const PaymentWebViewRouteArgs({this.key, required this.paymentUrl});

  final _i51.Key? key;

  final String paymentUrl;

  @override
  String toString() {
    return 'PaymentWebViewRouteArgs{key: $key, paymentUrl: $paymentUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentWebViewRouteArgs) return false;
    return key == other.key && paymentUrl == other.paymentUrl;
  }

  @override
  int get hashCode => key.hashCode ^ paymentUrl.hashCode;
}

/// generated route for
/// [_i34.PayrollScreen]
class PayrollRoute extends _i50.PageRouteInfo<PayrollRouteArgs> {
  PayrollRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          PayrollRoute.name,
          args: PayrollRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'PayrollRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PayrollRouteArgs>();
      return _i34.PayrollScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class PayrollRouteArgs {
  const PayrollRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'PayrollRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PayrollRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i35.ProfileEditScreen]
class ProfileEditRoute extends _i50.PageRouteInfo<ProfileEditRouteArgs> {
  ProfileEditRoute({
    _i51.Key? key,
    required _i53.Customer customer,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ProfileEditRoute.name,
          args: ProfileEditRouteArgs(key: key, customer: customer),
          initialChildren: children,
        );

  static const String name = 'ProfileEditRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileEditRouteArgs>();
      return _i35.ProfileEditScreen(key: args.key, customer: args.customer);
    },
  );
}

class ProfileEditRouteArgs {
  const ProfileEditRouteArgs({this.key, required this.customer});

  final _i51.Key? key;

  final _i53.Customer customer;

  @override
  String toString() {
    return 'ProfileEditRouteArgs{key: $key, customer: $customer}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileEditRouteArgs) return false;
    return key == other.key && customer == other.customer;
  }

  @override
  int get hashCode => key.hashCode ^ customer.hashCode;
}

/// generated route for
/// [_i36.ProfileSetupScreen]
class ProfileSetupRoute extends _i50.PageRouteInfo<ProfileSetupRouteArgs> {
  ProfileSetupRoute({
    _i51.Key? key,
    bool returnResult = false,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ProfileSetupRoute.name,
          args: ProfileSetupRouteArgs(key: key, returnResult: returnResult),
          initialChildren: children,
        );

  static const String name = 'ProfileSetupRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileSetupRouteArgs>(
        orElse: () => const ProfileSetupRouteArgs(),
      );
      return _i36.ProfileSetupScreen(
        key: args.key,
        returnResult: args.returnResult,
      );
    },
  );
}

class ProfileSetupRouteArgs {
  const ProfileSetupRouteArgs({this.key, this.returnResult = false});

  final _i51.Key? key;

  final bool returnResult;

  @override
  String toString() {
    return 'ProfileSetupRouteArgs{key: $key, returnResult: $returnResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileSetupRouteArgs) return false;
    return key == other.key && returnResult == other.returnResult;
  }

  @override
  int get hashCode => key.hashCode ^ returnResult.hashCode;
}

/// generated route for
/// [_i37.RegisterScreen]
class RegisterRoute extends _i50.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    _i51.Key? key,
    bool returnResult = false,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          RegisterRoute.name,
          args: RegisterRouteArgs(key: key, returnResult: returnResult),
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return _i37.RegisterScreen(
        key: args.key,
        returnResult: args.returnResult,
      );
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key, this.returnResult = false});

  final _i51.Key? key;

  final bool returnResult;

  @override
  String toString() {
    return 'RegisterRouteArgs{key: $key, returnResult: $returnResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegisterRouteArgs) return false;
    return key == other.key && returnResult == other.returnResult;
  }

  @override
  int get hashCode => key.hashCode ^ returnResult.hashCode;
}

/// generated route for
/// [_i38.ReviewScreen]
class ReviewRoute extends _i50.PageRouteInfo<ReviewRouteArgs> {
  ReviewRoute({
    _i51.Key? key,
    required int bookingId,
    required int customerId,
    required String hotelName,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ReviewRoute.name,
          args: ReviewRouteArgs(
            key: key,
            bookingId: bookingId,
            customerId: customerId,
            hotelName: hotelName,
          ),
          initialChildren: children,
        );

  static const String name = 'ReviewRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReviewRouteArgs>();
      return _i38.ReviewScreen(
        key: args.key,
        bookingId: args.bookingId,
        customerId: args.customerId,
        hotelName: args.hotelName,
      );
    },
  );
}

class ReviewRouteArgs {
  const ReviewRouteArgs({
    this.key,
    required this.bookingId,
    required this.customerId,
    required this.hotelName,
  });

  final _i51.Key? key;

  final int bookingId;

  final int customerId;

  final String hotelName;

  @override
  String toString() {
    return 'ReviewRouteArgs{key: $key, bookingId: $bookingId, customerId: $customerId, hotelName: $hotelName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReviewRouteArgs) return false;
    return key == other.key &&
        bookingId == other.bookingId &&
        customerId == other.customerId &&
        hotelName == other.hotelName;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      bookingId.hashCode ^
      customerId.hashCode ^
      hotelName.hashCode;
}

/// generated route for
/// [_i39.RoomDetailScreen]
class RoomDetailRoute extends _i50.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i51.Key? key,
    required int roomId,
    required int hotelId,
    DateTime? checkin,
    DateTime? checkout,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          RoomDetailRoute.name,
          args: RoomDetailRouteArgs(
            key: key,
            roomId: roomId,
            hotelId: hotelId,
            checkin: checkin,
            checkout: checkout,
          ),
          initialChildren: children,
        );

  static const String name = 'RoomDetailRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RoomDetailRouteArgs>();
      return _i39.RoomDetailScreen(
        key: args.key,
        roomId: args.roomId,
        hotelId: args.hotelId,
        checkin: args.checkin,
        checkout: args.checkout,
      );
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({
    this.key,
    required this.roomId,
    required this.hotelId,
    this.checkin,
    this.checkout,
  });

  final _i51.Key? key;

  final int roomId;

  final int hotelId;

  final DateTime? checkin;

  final DateTime? checkout;

  @override
  String toString() {
    return 'RoomDetailRouteArgs{key: $key, roomId: $roomId, hotelId: $hotelId, checkin: $checkin, checkout: $checkout}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomDetailRouteArgs) return false;
    return key == other.key &&
        roomId == other.roomId &&
        hotelId == other.hotelId &&
        checkin == other.checkin &&
        checkout == other.checkout;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      roomId.hashCode ^
      hotelId.hashCode ^
      checkin.hashCode ^
      checkout.hashCode;
}

/// generated route for
/// [_i40.RoomFormScreen]
class RoomFormRoute extends _i50.PageRouteInfo<RoomFormRouteArgs> {
  RoomFormRoute({
    _i51.Key? key,
    required int hotelId,
    _i55.Room? room,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          RoomFormRoute.name,
          args: RoomFormRouteArgs(key: key, hotelId: hotelId, room: room),
          initialChildren: children,
        );

  static const String name = 'RoomFormRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RoomFormRouteArgs>();
      return _i40.RoomFormScreen(
        key: args.key,
        hotelId: args.hotelId,
        room: args.room,
      );
    },
  );
}

class RoomFormRouteArgs {
  const RoomFormRouteArgs({this.key, required this.hotelId, this.room});

  final _i51.Key? key;

  final int hotelId;

  final _i55.Room? room;

  @override
  String toString() {
    return 'RoomFormRouteArgs{key: $key, hotelId: $hotelId, room: $room}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomFormRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId && room == other.room;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode ^ room.hashCode;
}

/// generated route for
/// [_i41.RoomManageDetailScreen]
class RoomManageDetailRoute
    extends _i50.PageRouteInfo<RoomManageDetailRouteArgs> {
  RoomManageDetailRoute({
    _i51.Key? key,
    required int hotelId,
    required int roomId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          RoomManageDetailRoute.name,
          args: RoomManageDetailRouteArgs(
            key: key,
            hotelId: hotelId,
            roomId: roomId,
          ),
          initialChildren: children,
        );

  static const String name = 'RoomManageDetailRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RoomManageDetailRouteArgs>();
      return _i41.RoomManageDetailScreen(
        key: args.key,
        hotelId: args.hotelId,
        roomId: args.roomId,
      );
    },
  );
}

class RoomManageDetailRouteArgs {
  const RoomManageDetailRouteArgs({
    this.key,
    required this.hotelId,
    required this.roomId,
  });

  final _i51.Key? key;

  final int hotelId;

  final int roomId;

  @override
  String toString() {
    return 'RoomManageDetailRouteArgs{key: $key, hotelId: $hotelId, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomManageDetailRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i42.RoomsManageScreen]
class RoomsManageRoute extends _i50.PageRouteInfo<void> {
  const RoomsManageRoute({List<_i50.PageRouteInfo>? children})
      : super(RoomsManageRoute.name, initialChildren: children);

  static const String name = 'RoomsManageRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i42.RoomsManageScreen();
    },
  );
}

/// generated route for
/// [_i43.SearchResultsScreen]
class SearchResultsRoute extends _i50.PageRouteInfo<SearchResultsRouteArgs> {
  SearchResultsRoute({
    _i51.Key? key,
    required DateTime checkin,
    required DateTime checkout,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          SearchResultsRoute.name,
          args: SearchResultsRouteArgs(
            key: key,
            checkin: checkin,
            checkout: checkout,
          ),
          initialChildren: children,
        );

  static const String name = 'SearchResultsRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchResultsRouteArgs>();
      return _i43.SearchResultsScreen(
        key: args.key,
        checkin: args.checkin,
        checkout: args.checkout,
      );
    },
  );
}

class SearchResultsRouteArgs {
  const SearchResultsRouteArgs({
    this.key,
    required this.checkin,
    required this.checkout,
  });

  final _i51.Key? key;

  final DateTime checkin;

  final DateTime checkout;

  @override
  String toString() {
    return 'SearchResultsRouteArgs{key: $key, checkin: $checkin, checkout: $checkout}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchResultsRouteArgs) return false;
    return key == other.key &&
        checkin == other.checkin &&
        checkout == other.checkout;
  }

  @override
  int get hashCode => key.hashCode ^ checkin.hashCode ^ checkout.hashCode;
}

/// generated route for
/// [_i44.ServicesScreen]
class ServicesRoute extends _i50.PageRouteInfo<ServicesRouteArgs> {
  ServicesRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ServicesRoute.name,
          args: ServicesRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'ServicesRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServicesRouteArgs>();
      return _i44.ServicesScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class ServicesRouteArgs {
  const ServicesRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'ServicesRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServicesRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i45.SplashScreen]
class SplashRoute extends _i50.PageRouteInfo<void> {
  const SplashRoute({List<_i50.PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i45.SplashScreen();
    },
  );
}

/// generated route for
/// [_i46.SystemDataScreen]
class SystemDataRoute extends _i50.PageRouteInfo<void> {
  const SystemDataRoute({List<_i50.PageRouteInfo>? children})
      : super(SystemDataRoute.name, initialChildren: children);

  static const String name = 'SystemDataRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i46.SystemDataScreen();
    },
  );
}

/// generated route for
/// [_i47.WalkInBookingScreen]
class WalkInBookingRoute extends _i50.PageRouteInfo<WalkInBookingRouteArgs> {
  WalkInBookingRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          WalkInBookingRoute.name,
          args: WalkInBookingRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'WalkInBookingRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WalkInBookingRouteArgs>();
      return _i47.WalkInBookingScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class WalkInBookingRouteArgs {
  const WalkInBookingRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'WalkInBookingRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalkInBookingRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [_i48.WorkspaceMoreScreen]
class WorkspaceMoreRoute extends _i50.PageRouteInfo<void> {
  const WorkspaceMoreRoute({List<_i50.PageRouteInfo>? children})
      : super(WorkspaceMoreRoute.name, initialChildren: children);

  static const String name = 'WorkspaceMoreRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      return const _i48.WorkspaceMoreScreen();
    },
  );
}

/// generated route for
/// [_i49.WorkspaceShellScreen]
class WorkspaceShellRoute extends _i50.PageRouteInfo<WorkspaceShellRouteArgs> {
  WorkspaceShellRoute({
    _i51.Key? key,
    required int hotelId,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          WorkspaceShellRoute.name,
          args: WorkspaceShellRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'WorkspaceShellRoute';

  static _i50.PageInfo page = _i50.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkspaceShellRouteArgs>();
      return _i49.WorkspaceShellScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class WorkspaceShellRouteArgs {
  const WorkspaceShellRouteArgs({this.key, required this.hotelId});

  final _i51.Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'WorkspaceShellRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkspaceShellRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}
