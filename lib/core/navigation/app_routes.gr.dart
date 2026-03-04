// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_routes.dart';

/// generated route for
/// [AmenityScreen]
class AmenityRoute extends PageRouteInfo<AmenityRouteArgs> {
  AmenityRoute({
    Key? key,
    int? hotelId,
    int? roomId,
    List<PageRouteInfo>? children,
  }) : super(
          AmenityRoute.name,
          args: AmenityRouteArgs(key: key, hotelId: hotelId, roomId: roomId),
          initialChildren: children,
        );

  static const String name = 'AmenityRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AmenityRouteArgs>(
        orElse: () => const AmenityRouteArgs(),
      );
      return AmenityScreen(
        key: args.key,
        hotelId: args.hotelId,
        roomId: args.roomId,
      );
    },
  );
}

class AmenityRouteArgs {
  const AmenityRouteArgs({this.key, this.hotelId, this.roomId});

  final Key? key;

  final int? hotelId;

  final int? roomId;

  @override
  String toString() {
    return 'AmenityRouteArgs{key: $key, hotelId: $hotelId, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AmenityRouteArgs) return false;
    return key == other.key &&
        hotelId == other.hotelId &&
        roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [BookingAdminScreen]
class BookingAdminRoute extends PageRouteInfo<BookingAdminRouteArgs> {
  BookingAdminRoute({
    Key? key,
    int? customerId,
    int? hotelId,
    List<PageRouteInfo>? children,
  }) : super(
          BookingAdminRoute.name,
          args: BookingAdminRouteArgs(
            key: key,
            customerId: customerId,
            hotelId: hotelId,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingAdminRouteArgs>(
        orElse: () => const BookingAdminRouteArgs(),
      );
      return BookingAdminScreen(
        key: args.key,
        customerId: args.customerId,
        hotelId: args.hotelId,
      );
    },
  );
}

class BookingAdminRouteArgs {
  const BookingAdminRouteArgs({this.key, this.customerId, this.hotelId});

  final Key? key;

  final int? customerId;

  final int? hotelId;

  @override
  String toString() {
    return 'BookingAdminRouteArgs{key: $key, customerId: $customerId, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingAdminRouteArgs) return false;
    return key == other.key &&
        customerId == other.customerId &&
        hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [CreateCustomerScreen]
class CreateCustomerRoute extends PageRouteInfo<CreateCustomerRouteArgs> {
  CreateCustomerRoute({
    required String accountId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CreateCustomerRoute.name,
          args: CreateCustomerRouteArgs(accountId: accountId, key: key),
          rawPathParams: {'accountId': accountId},
          initialChildren: children,
        );

  static const String name = 'CreateCustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreateCustomerRouteArgs>(
        orElse: () => CreateCustomerRouteArgs(
          accountId: pathParams.getString('accountId'),
        ),
      );
      return CreateCustomerScreen(accountId: args.accountId, key: args.key);
    },
  );
}

class CreateCustomerRouteArgs {
  const CreateCustomerRouteArgs({required this.accountId, this.key});

  final String accountId;

  final Key? key;

  @override
  String toString() {
    return 'CreateCustomerRouteArgs{accountId: $accountId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateCustomerRouteArgs) return false;
    return accountId == other.accountId && key == other.key;
  }

  @override
  int get hashCode => accountId.hashCode ^ key.hashCode;
}

/// generated route for
/// [CustomerScreen]
class CustomerRoute extends PageRouteInfo<void> {
  const CustomerRoute({List<PageRouteInfo>? children})
      : super(CustomerRoute.name, initialChildren: children);

  static const String name = 'CustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CustomerScreen();
    },
  );
}

/// generated route for
/// [EmployeeScreen]
class EmployeeRoute extends PageRouteInfo<void> {
  const EmployeeRoute({List<PageRouteInfo>? children})
      : super(EmployeeRoute.name, initialChildren: children);

  static const String name = 'EmployeeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EmployeeScreen();
    },
  );
}

/// generated route for
/// [HotelDetailScreen]
class HotelDetailRoute extends PageRouteInfo<HotelDetailRouteArgs> {
  HotelDetailRoute({
    Key? key,
    required Hotel hotel,
    String? checkinDate,
    String? checkoutDate,
    List<PageRouteInfo>? children,
  }) : super(
          HotelDetailRoute.name,
          args: HotelDetailRouteArgs(
            key: key,
            hotel: hotel,
            checkinDate: checkinDate,
            checkoutDate: checkoutDate,
          ),
          initialChildren: children,
        );

  static const String name = 'HotelDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HotelDetailRouteArgs>();
      return HotelDetailScreen(
        key: args.key,
        hotel: args.hotel,
        checkinDate: args.checkinDate,
        checkoutDate: args.checkoutDate,
      );
    },
  );
}

class HotelDetailRouteArgs {
  const HotelDetailRouteArgs({
    this.key,
    required this.hotel,
    this.checkinDate,
    this.checkoutDate,
  });

  final Key? key;

  final Hotel hotel;

  final String? checkinDate;

  final String? checkoutDate;

  @override
  String toString() {
    return 'HotelDetailRouteArgs{key: $key, hotel: $hotel, checkinDate: $checkinDate, checkoutDate: $checkoutDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HotelDetailRouteArgs) return false;
    return key == other.key &&
        hotel == other.hotel &&
        checkinDate == other.checkinDate &&
        checkoutDate == other.checkoutDate;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      hotel.hashCode ^
      checkinDate.hashCode ^
      checkoutDate.hashCode;
}

/// generated route for
/// [HotelListScreen]
class HotelListRoute extends PageRouteInfo<void> {
  const HotelListRoute({List<PageRouteInfo>? children})
      : super(HotelListRoute.name, initialChildren: children);

  static const String name = 'HotelListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HotelListScreen();
    },
  );
}

/// generated route for
/// [HotelManageListScreen]
class HotelManageListRoute extends PageRouteInfo<void> {
  const HotelManageListRoute({List<PageRouteInfo>? children})
      : super(HotelManageListRoute.name, initialChildren: children);

  static const String name = 'HotelManageListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HotelManageListScreen();
    },
  );
}

/// generated route for
/// [HotelManageScreen]
class HotelManageRoute extends PageRouteInfo<HotelManageRouteArgs> {
  HotelManageRoute({
    Key? key,
    required int hotelId,
    List<PageRouteInfo>? children,
  }) : super(
          HotelManageRoute.name,
          args: HotelManageRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'HotelManageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HotelManageRouteArgs>();
      return HotelManageScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class HotelManageRouteArgs {
  const HotelManageRouteArgs({this.key, required this.hotelId});

  final Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'HotelManageRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HotelManageRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [PositionScreen]
class PositionRoute extends PageRouteInfo<void> {
  const PositionRoute({List<PageRouteInfo>? children})
      : super(PositionRoute.name, initialChildren: children);

  static const String name = 'PositionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PositionScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [RoomDetailScreen]
class RoomDetailRoute extends PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    Key? key,
    required int roomId,
    String? statusRoom,
    bool isHotelManager = false,
    List<PageRouteInfo>? children,
  }) : super(
          RoomDetailRoute.name,
          args: RoomDetailRouteArgs(
            key: key,
            roomId: roomId,
            statusRoom: statusRoom,
            isHotelManager: isHotelManager,
          ),
          initialChildren: children,
        );

  static const String name = 'RoomDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RoomDetailRouteArgs>();
      return RoomDetailScreen(
        key: args.key,
        roomId: args.roomId,
        statusRoom: args.statusRoom,
        isHotelManager: args.isHotelManager,
      );
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({
    this.key,
    required this.roomId,
    this.statusRoom,
    this.isHotelManager = false,
  });

  final Key? key;

  final int roomId;

  final String? statusRoom;

  final bool isHotelManager;

  @override
  String toString() {
    return 'RoomDetailRouteArgs{key: $key, roomId: $roomId, statusRoom: $statusRoom, isHotelManager: $isHotelManager}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomDetailRouteArgs) return false;
    return key == other.key &&
        roomId == other.roomId &&
        statusRoom == other.statusRoom &&
        isHotelManager == other.isHotelManager;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      roomId.hashCode ^
      statusRoom.hashCode ^
      isHotelManager.hashCode;
}

/// generated route for
/// [RoomScreen]
class RoomRoute extends PageRouteInfo<RoomRouteArgs> {
  RoomRoute({Key? key, required int hotelId, List<PageRouteInfo>? children})
      : super(
          RoomRoute.name,
          args: RoomRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'RoomRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RoomRouteArgs>();
      return RoomScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class RoomRouteArgs {
  const RoomRouteArgs({this.key, required this.hotelId});

  final Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'RoomRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [RoomTypeScreen]
class RoomTypeRoute extends PageRouteInfo<void> {
  const RoomTypeRoute({List<PageRouteInfo>? children})
      : super(RoomTypeRoute.name, initialChildren: children);

  static const String name = 'RoomTypeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RoomTypeScreen();
    },
  );
}

/// generated route for
/// [ServiceScreen]
class ServiceRoute extends PageRouteInfo<ServiceRouteArgs> {
  ServiceRoute({Key? key, int? hotelId, List<PageRouteInfo>? children})
      : super(
          ServiceRoute.name,
          args: ServiceRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'ServiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServiceRouteArgs>(
        orElse: () => const ServiceRouteArgs(),
      );
      return ServiceScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class ServiceRouteArgs {
  const ServiceRouteArgs({this.key, this.hotelId});

  final Key? key;

  final int? hotelId;

  @override
  String toString() {
    return 'ServiceRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServiceRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [StaffAdminScreen]
class StaffAdminRoute extends PageRouteInfo<StaffAdminRouteArgs> {
  StaffAdminRoute({
    Key? key,
    required int hotelId,
    List<PageRouteInfo>? children,
  }) : super(
          StaffAdminRoute.name,
          args: StaffAdminRouteArgs(key: key, hotelId: hotelId),
          initialChildren: children,
        );

  static const String name = 'StaffAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StaffAdminRouteArgs>();
      return StaffAdminScreen(key: args.key, hotelId: args.hotelId);
    },
  );
}

class StaffAdminRouteArgs {
  const StaffAdminRouteArgs({this.key, required this.hotelId});

  final Key? key;

  final int hotelId;

  @override
  String toString() {
    return 'StaffAdminRouteArgs{key: $key, hotelId: $hotelId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StaffAdminRouteArgs) return false;
    return key == other.key && hotelId == other.hotelId;
  }

  @override
  int get hashCode => key.hashCode ^ hotelId.hashCode;
}
