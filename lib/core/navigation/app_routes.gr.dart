// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_routes.dart';

/// generated route for
/// [BookingScreen]
class BookingRoute extends PageRouteInfo<void> {
  const BookingRoute({List<PageRouteInfo>? children})
      : super(BookingRoute.name, initialChildren: children);

  static const String name = 'BookingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BookingScreen();
    },
  );
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
/// [HotelManagerScreen]
class HotelManagerRoute extends PageRouteInfo<void> {
  const HotelManagerRoute({List<PageRouteInfo>? children})
      : super(HotelManagerRoute.name, initialChildren: children);

  static const String name = 'HotelManagerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HotelManagerScreen();
    },
  );
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
class ServiceRoute extends PageRouteInfo<void> {
  const ServiceRoute({List<PageRouteInfo>? children})
      : super(ServiceRoute.name, initialChildren: children);

  static const String name = 'ServiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServiceScreen();
    },
  );
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
/// [StaffScreen]
class StaffRoute extends PageRouteInfo<void> {
  const StaffRoute({List<PageRouteInfo>? children})
      : super(StaffRoute.name, initialChildren: children);

  static const String name = 'StaffRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StaffScreen();
    },
  );
}
