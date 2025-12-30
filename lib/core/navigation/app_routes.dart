import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/customer/presentation/screen/create_customer_screen.dart';
import '../../features/customer/presentation/screen/profile_screen.dart';
import '../../features/position/presentation/screen/position_screen.dart';
import '../../features/admin/presentation/screen/admin_home_screen.dart'; // renamed class inside to HotelManagerScreen
import '../../features/admin/presentation/screen/staff_screen.dart';
import '../../features/room_type/presentation/screen/room_type_screen.dart';
import '../../features/room/presentation/screen/room_screen.dart';
import '../../features/service/presentation/screen/service_screen.dart';
import '../../features/admin/presentation/screen/booking_screen.dart';
import '../../features/auth/presentation/login/screen/login_screen.dart';
import '../../features/auth/presentation/register/screen/register_screen.dart';
import '../../features/customer/presentation/screen/customer_screen.dart';
import '../../features/start/start_screen.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRoutes extends RootStackRouter {
  AppRoutes();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            path: '/${SplashRoute.name}',
            page: SplashRoute.page,
            initial: true),
        AutoRoute(
          path: '/${ProfileRoute.name}',
          page: ProfileRoute.page,
        ),
        AutoRoute(
          path: '/${CreateCustomerRoute.name}/:accountId',
          page: CreateCustomerRoute.page,
        ),
        AutoRoute(
          path: '/${LoginRoute.name}',
          page: LoginRoute.page,
        ),
        AutoRoute(
          path: '/${RegisterRoute.name}',
          page: RegisterRoute.page,
        ),
        AutoRoute(
          path: '/${HotelManagerRoute.name}',
          page: HotelManagerRoute.page,
        ),
        AutoRoute(
          path: '/${PositionRoute.name}',
          page: PositionRoute.page,
        ),
        AutoRoute(
          path: '/${CustomerRoute.name}',
          page: CustomerRoute.page,
        ),
        AutoRoute(
          path: '/${StaffRoute.name}',
          page: StaffRoute.page,
        ),
        AutoRoute(
          path: '/${RoomTypeRoute.name}',
          page: RoomTypeRoute.page,
        ),
        AutoRoute(
          path: '/${RoomRoute.name}',
          page: RoomRoute.page,
        ),
        AutoRoute(
          path: '/${ServiceRoute.name}',
          page: ServiceRoute.page,
        ),
        AutoRoute(
          path: '/${BookingRoute.name}',
          page: BookingRoute.page,
        ),
      ];
}
