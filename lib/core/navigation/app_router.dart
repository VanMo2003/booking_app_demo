import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

export 'app_router.gr.dart';

/// Toàn bộ tuyến điều hướng của app. Lớp `XRoute` sinh ra từ các màn gắn
/// `@RoutePage` (chạy `dart run build_runner build`).
///
/// Mỗi vai trò có một khung tab riêng; các màn chi tiết/biểu mẫu nằm ở cấp gốc
/// để mở toàn màn hình phía trên khung tab.
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),

        // Đăng nhập, đăng ký, hồ sơ khách
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: ProfileSetupRoute.page),
        AutoRoute(page: ProfileEditRoute.page),

        // Thông báo — mọi vai trò
        AutoRoute(page: NotificationsRoute.page),

        // Khách vãng lai & khách hàng
        AutoRoute(
          page: CustomerShellRoute.page,
          children: [
            AutoRoute(page: ExploreRoute.page),
            AutoRoute(page: MyBookingsRoute.page),
            AutoRoute(page: FavoritesRoute.page),
            AutoRoute(page: AccountRoute.page),
          ],
        ),
        AutoRoute(page: SearchResultsRoute.page),
        AutoRoute(page: HotelDetailRoute.page),
        AutoRoute(page: RoomDetailRoute.page),
        AutoRoute(page: BookingCreateRoute.page),
        AutoRoute(page: BookingDetailRoute.page),
        AutoRoute(page: PaymentWebViewRoute.page),
        AutoRoute(page: ReviewRoute.page),

        // Nhân viên & quản lý cơ sở
        AutoRoute(page: BranchPickerRoute.page),
        AutoRoute(
          page: WorkspaceShellRoute.page,
          children: [
            AutoRoute(page: DashboardRoute.page),
            AutoRoute(page: DeskRoute.page),
            AutoRoute(page: RoomsManageRoute.page),
            AutoRoute(page: BranchCustomersRoute.page),
            AutoRoute(page: BranchReportsRoute.page),
            AutoRoute(page: WorkspaceMoreRoute.page),
          ],
        ),
        AutoRoute(page: WalkInBookingRoute.page),
        AutoRoute(page: BookingEditRoute.page),
        AutoRoute(page: RoomFormRoute.page),
        AutoRoute(page: RoomManageDetailRoute.page),
        AutoRoute(page: AmenitiesRoute.page),
        AutoRoute(page: ServicesRoute.page),
        AutoRoute(page: CustomerDirectoryRoute.page),
        AutoRoute(page: CustomerDetailRoute.page),
        AutoRoute(page: EmployeesRoute.page),
        AutoRoute(page: EmployeeFormRoute.page),
        AutoRoute(page: PayrollRoute.page),
        AutoRoute(page: BranchInfoRoute.page),

        // Đối tác: đăng ký chủ khách sạn, chờ duyệt, sửa / gửi lại hồ sơ
        AutoRoute(page: OwnerRegisterRoute.page),
        AutoRoute(page: OwnerStatusRoute.page),
        AutoRoute(page: OwnerProfileFormRoute.page),

        // Chủ khách sạn (đã được duyệt)
        AutoRoute(page: CreateChainRoute.page),
        AutoRoute(
          page: OwnerShellRoute.page,
          children: [
            AutoRoute(page: ChainOverviewRoute.page),
            AutoRoute(page: ChainBranchesRoute.page),
            AutoRoute(page: ChainReportsRoute.page),
            AutoRoute(page: OwnerMoreRoute.page),
          ],
        ),
        AutoRoute(page: BranchFormRoute.page),
        AutoRoute(page: ManagersRoute.page),
        AutoRoute(page: ChainInfoRoute.page),

        // Quản trị hệ thống — xem và xét duyệt
        AutoRoute(
          page: AdminShellRoute.page,
          children: [
            AutoRoute(page: AdminOverviewRoute.page),
            AutoRoute(page: OwnerApprovalsRoute.page),
            AutoRoute(page: AccountsRoute.page),
            AutoRoute(page: CatalogRoute.page),
            AutoRoute(page: SystemDataRoute.page),
          ],
        ),
        AutoRoute(page: OwnerRegistrationDetailRoute.page),
      ];
}
