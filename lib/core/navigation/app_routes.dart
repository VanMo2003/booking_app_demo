import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/amenity/presentation/screen/amenity_screen.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:flutter/material.dart';
import 'package:collection/equality.dart';

import '../../features/customer/presentation/screen/create_customer_screen.dart';
import '../../features/customer/presentation/screen/hotel_detail_screen.dart';
import '../../features/customer/presentation/screen/profile_screen.dart';
import '../../features/employee/presentation/screen/employee_screen.dart';
import '../../features/hotel/presentation/screen/hotel_list_screen.dart';
import '../../features/hotel_manage/presentation/screen/hotel_manage_screen.dart';
import '../../features/hotel_manage/presentation/screen/booking_screen.dart';
import '../../features/hotel_manage/presentation/screen/staff_admin_screen.dart';
import '../../features/position/presentation/screen/position_screen.dart';
import '../../features/room_type/presentation/screen/room_type_screen.dart';
import '../../features/room/presentation/screen/room_screen.dart';
import '../../features/service/presentation/screen/service_screen.dart';
import '../../features/auth/presentation/login/screen/login_screen.dart';
import '../../features/auth/presentation/register/screen/register_screen.dart';
import '../../features/customer/presentation/screen/customer_screen.dart';
import '../../features/splash/splash_screen.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRoutes extends RootStackRouter {
  AppRoutes();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/${SplashRoute.name}', page: SplashRoute.page, initial: true),
        AutoRoute(
          path: '/${StaffAdminRoute.name}',
          page: StaffAdminRoute.page,
        ),
        AutoRoute(
          path: '/${HotelDetailRoute.name}',
          page: HotelDetailRoute.page,
        ),
        AutoRoute(
          path: '/${AmenityRoute.name}',
          page: AmenityRoute.page,
        ),
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
          path: '/${HotelManageRoute.name}',
          page: HotelManageRoute.page,
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
          path: '/${EmployeeRoute.name}',
          page: EmployeeRoute.page,
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
        AutoRoute(
          path: '/${HotelListRoute.name}',
          page: HotelListRoute.page,
        ),
      ];
}
