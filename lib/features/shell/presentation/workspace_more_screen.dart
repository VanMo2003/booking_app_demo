import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/chat_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/menu_strings.dart';
import '../../../core/text/tour_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../../chat/presentation/chat_hub.dart';
import 'workspace_scope.dart';

@RoutePage()
class WorkspaceMoreScreen extends StatelessWidget {
  const WorkspaceMoreScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmLabel: AppStrings.logout,
      destructive: true,
    );
    if (confirmed && context.mounted) await SessionNavigator.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final session = context.watch<SessionCubit>().state.session;
    final branchName = context.branchName;
    final hotelId = scope.hotelId;
    final router = context.rootRouter;
    if (session == null) return const SizedBox.shrink();

    return AppPage(
      title: WorkspaceStrings.tabMore,
      subtitle: branchName,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          AppCard(
            child: Row(
              children: [
                AppAvatar(name: session.displayName, size: 52),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.displayName, style: AppTextStyles.subtitle),
                      // Quản lý chưa có hồ sơ riêng nên tên hiển thị chính là tên đăng nhập.
                      if (session.displayName != session.username)
                        Text('@${session.username}', style: AppTextStyles.caption),
                      const Gap(6),
                      StatusBadge.role(session.role, dense: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          MenuGroup(
            title: WorkspaceStrings.groupOperations,
            children: [
              if (session.role != Role.admin)
                MenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: ChatStrings.branchInbox,
                  trailing: BlocBuilder<ChatUnreadCubit, int>(
                    builder: (context, unread) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unread > 0)
                          Badge(
                            backgroundColor: AppColors.danger,
                            label: Text(ChatStrings.unreadCount(unread)),
                          ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
                      ],
                    ),
                  ),
                  onTap: () => router.push(
                    BranchChatInboxRoute(hotelId: hotelId, branchName: branchName),
                  ),
                ),
              MenuTile(
                icon: Icons.add_business_outlined,
                title: WorkspaceStrings.menuWalkIn,
                onTap: () => router.push(WalkInBookingRoute(hotelId: hotelId)),
              ),
              MenuTile(
                icon: Icons.checklist_rounded,
                title: WorkspaceStrings.menuAmenities,
                onTap: () => router.push(AmenitiesRoute(hotelId: hotelId)),
              ),
              MenuTile(
                icon: Icons.room_service_outlined,
                title: WorkspaceStrings.menuServices,
                onTap: () => router.push(ServicesRoute(hotelId: hotelId)),
              ),
              MenuTile(
                icon: Icons.restaurant_menu_rounded,
                title: MenuStrings.title,
                onTap: () => router.push(DishesRoute(hotelId: hotelId)),
              ),
              MenuTile(
                icon: Icons.tour_outlined,
                title: TourStrings.title,
                onTap: () => router.push(ToursRoute(hotelId: hotelId)),
              ),
              if (scope.canManage)
                MenuTile(
                  icon: Icons.groups_outlined,
                  title: WorkspaceStrings.menuCustomers,
                  onTap: () => router.push(CustomerDirectoryRoute(hotelId: hotelId)),
                ),
            ],
          ),
          if (scope.canManage) ...[
            const Gap(AppSpacing.md),
            MenuGroup(
              title: WorkspaceStrings.groupPeople,
              children: [
                MenuTile(
                  icon: Icons.badge_outlined,
                  title: WorkspaceStrings.menuEmployees,
                  onTap: () => router.push(EmployeesRoute(hotelId: hotelId)),
                ),
                MenuTile(
                  icon: Icons.request_quote_outlined,
                  title: WorkspaceStrings.menuPayroll,
                  onTap: () => router.push(PayrollRoute(hotelId: hotelId)),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            MenuGroup(
              title: WorkspaceStrings.groupBranch,
              children: [
                MenuTile(
                  icon: Icons.storefront_outlined,
                  title: WorkspaceStrings.menuBranchInfo,
                  subtitle: branchName,
                  onTap: () async {
                    await router.push(BranchInfoRoute(hotelId: hotelId));
                    if (context.mounted) await context.read<BranchCubit>().load();
                  },
                ),
              ],
            ),
          ],
          const Gap(AppSpacing.md),
          MenuGroup(
            title: WorkspaceStrings.groupAccount,
            children: [
              if (session.role == Role.hotelManager && session.hotels.length > 1)
                MenuTile(
                  icon: Icons.swap_horiz_rounded,
                  title: WorkspaceStrings.menuSwitchBranch,
                  onTap: () => router.replaceAll([const BranchPickerRoute()]),
                ),
              if (session.role == Role.hotelOwner)
                MenuTile(
                  icon: Icons.apartment_rounded,
                  title: WorkspaceStrings.menuBackToChain,
                  onTap: () => router.maybePop(),
                ),
              if (session.role == Role.admin)
                MenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: WorkspaceStrings.menuBackToAdmin,
                  onTap: () => router.maybePop(),
                ),
              if (session.role == Role.staff || session.role == Role.hotelManager)
                MenuTile(
                  icon: Icons.logout_rounded,
                  title: AppStrings.logout,
                  subtitle: session.role.label,
                  destructive: true,
                  onTap: () => _logout(context),
                ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Text(
            AppStrings.version,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.colored(AppColors.inkTertiary),
          ),
        ],
      ),
    );
  }
}
