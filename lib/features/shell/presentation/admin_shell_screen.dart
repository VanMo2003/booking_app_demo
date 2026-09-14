import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/management_strings.dart';

/// Khung cho quản trị viên: Tổng quan · Tài khoản · Danh mục · Hệ thống.
@RoutePage()
class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        AdminOverviewRoute(),
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
            child: NavigationBar(
              selectedIndex: tabs.activeIndex,
              onDestinationSelected: tabs.setActiveIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard_rounded),
                  label: ManagementStrings.tabAdminOverview,
                ),
                NavigationDestination(
                  icon: Icon(Icons.manage_accounts_outlined),
                  selectedIcon: Icon(Icons.manage_accounts_rounded),
                  label: ManagementStrings.tabAccounts,
                ),
                NavigationDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category_rounded),
                  label: ManagementStrings.tabCatalog,
                ),
                NavigationDestination(
                  icon: Icon(Icons.storage_outlined),
                  selectedIcon: Icon(Icons.storage_rounded),
                  label: ManagementStrings.tabSystem,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
