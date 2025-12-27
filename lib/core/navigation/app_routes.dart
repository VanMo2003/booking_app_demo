import 'package:auto_route/auto_route.dart';

import '../../features/position/presentation/screen/position_screen.dart';
import '../../features/admin/presentation/screen/admin_home_screen.dart';
import '../../features/admin/presentation/screen/staff_screen.dart';
import '../../features/room_type/presentation/screen/room_type_screen.dart';
import '../../features/room/presentation/screen/room_screen.dart';
import '../../features/service/presentation/screen/service_screen.dart';
import '../../features/admin/presentation/screen/booking_screen.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRoutes extends RootStackRouter {
  final bool includeAuthRoutes;

  AppRoutes({this.includeAuthRoutes = false});

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/admin',
          page: AdminHomeRoute.page,
          initial: includeAuthRoutes,
        ),
        AutoRoute(
          path: '/${PositionRoute.name}',
          page: PositionRoute.page,
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
