import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/workspace_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import 'workspace_scope.dart';

/// Không gian làm việc tại một cơ sở. Nhân viên: Quầy · Phòng · Khách · Thêm.
/// Quản lý (và chủ khách sạn / quản trị khi vào cơ sở): thêm Tổng quan, Báo cáo.
@RoutePage()
class WorkspaceShellScreen extends StatelessWidget {
  const WorkspaceShellScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    final role = context.select((SessionCubit cubit) => cubit.state.role) ?? Role.staff;
    final manager = role.isManagerOrAbove;
    return WorkspaceScope(
      hotelId: hotelId,
      role: role,
      child: BlocProvider(
        create: (_) => getIt<BranchCubit>()..loadBranch(hotelId),
        child: AutoTabsRouter(
          routes: manager
              ? const [
                  DashboardRoute(),
                  DeskRoute(),
                  RoomsManageRoute(),
                  BranchReportsRoute(),
                  WorkspaceMoreRoute(),
                ]
              : const [
                  DeskRoute(),
                  RoomsManageRoute(),
                  BranchCustomersRoute(),
                  WorkspaceMoreRoute(),
                ],
          transitionBuilder: (context, child, animation) =>
              FadeTransition(opacity: animation, child: child),
          builder: (context, child) {
            final tabs = AutoTabsRouter.of(context);
            return Scaffold(
              body: child,
              bottomNavigationBar: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.lineSoft)),
                ),
                child: NavigationBar(
                  selectedIndex: tabs.activeIndex,
                  onDestinationSelected: tabs.setActiveIndex,
                  destinations: [
                    if (manager)
                      const NavigationDestination(
                        icon: Icon(Icons.space_dashboard_outlined),
                        selectedIcon: Icon(Icons.space_dashboard_rounded),
                        label: WorkspaceStrings.tabDashboard,
                      ),
                    const NavigationDestination(
                      icon: Icon(Icons.support_agent_outlined),
                      selectedIcon: Icon(Icons.support_agent_rounded),
                      label: WorkspaceStrings.tabDesk,
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.bed_outlined),
                      selectedIcon: Icon(Icons.bed_rounded),
                      label: WorkspaceStrings.tabRooms,
                    ),
                    if (manager)
                      const NavigationDestination(
                        icon: Icon(Icons.insights_outlined),
                        selectedIcon: Icon(Icons.insights_rounded),
                        label: WorkspaceStrings.tabReports,
                      )
                    else
                      const NavigationDestination(
                        icon: Icon(Icons.groups_outlined),
                        selectedIcon: Icon(Icons.groups_rounded),
                        label: WorkspaceStrings.tabCustomers,
                      ),
                    const NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: WorkspaceStrings.tabMore,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
