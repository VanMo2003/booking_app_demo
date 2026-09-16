import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/partner_strings.dart';
import '../../admin/presentation/owner_approvals_screen.dart';
import '../../notification/services/notification_events.dart';

/// Khung cho quản trị viên: Tổng quan · Xét duyệt · Tài khoản · Danh mục · Hệ thống.
/// Quản trị viên xem và xét duyệt — không tạo tài khoản, phòng, tiện ích, dịch vụ.
@RoutePage()
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  final _pending = getIt<PendingOwnersCubit>();
  StreamSubscription<void>? _events;

  @override
  void initState() {
    super.initState();
    _pending.refresh();
    _events = getIt<NotificationEvents>().onChanged.listen((_) => _pending.refresh());
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pending,
      child: AutoTabsRouter(
        routes: const [
          AdminOverviewRoute(),
          OwnerApprovalsRoute(),
          AccountsRoute(),
          CatalogRoute(),
          SystemDataRoute(),
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
              child: BlocBuilder<PendingOwnersCubit, int>(
                builder: (context, pending) => NavigationBar(
                  selectedIndex: tabs.activeIndex,
                  onDestinationSelected: tabs.setActiveIndex,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.space_dashboard_outlined),
                      selectedIcon: Icon(Icons.space_dashboard_rounded),
                      label: ManagementStrings.tabAdminOverview,
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: pending > 0,
                        label: Text('$pending'),
                        child: const Icon(Icons.fact_check_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: pending > 0,
                        label: Text('$pending'),
                        child: const Icon(Icons.fact_check_rounded),
                      ),
                      label: PartnerStrings.tabApprovals,
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.manage_accounts_outlined),
                      selectedIcon: Icon(Icons.manage_accounts_rounded),
                      label: ManagementStrings.tabAccounts,
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.category_outlined),
                      selectedIcon: Icon(Icons.category_rounded),
                      label: ManagementStrings.tabCatalog,
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.storage_outlined),
                      selectedIcon: Icon(Icons.storage_rounded),
                      label: ManagementStrings.tabSystem,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
