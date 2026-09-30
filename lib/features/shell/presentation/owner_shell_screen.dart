import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/chat_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../chat/presentation/chat_entry.dart';
import '../../hotel_chain/presentation/chain_cubits.dart';

/// Khung cho chủ khách sạn: Tổng quan · Cơ sở · Báo cáo · Tin nhắn · Thêm.
@RoutePage()
class OwnerShellScreen extends StatelessWidget {
  const OwnerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chainId = context.select(
      (SessionCubit cubit) => cubit.state.session?.hotelChain?.id,
    );
    if (chainId == null) return const Scaffold(body: AppLoadingView());
    return BlocProvider(
      key: ValueKey(chainId),
      create: (_) => getIt<ChainCubit>()..start(chainId),
      child: AutoTabsRouter(
        routes: const [
          ChainOverviewRoute(),
          ChainBranchesRoute(),
          ChainReportsRoute(),
          ChatInboxRoute(),
          OwnerMoreRoute(),
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
                    label: ManagementStrings.tabOverview,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.apartment_outlined),
                    selectedIcon: Icon(Icons.apartment_rounded),
                    label: ManagementStrings.tabBranches,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights_rounded),
                    label: ManagementStrings.tabReports,
                  ),
                  NavigationDestination(
                    icon: ChatBadge(child: Icon(Icons.chat_bubble_outline_rounded)),
                    selectedIcon: ChatBadge(child: Icon(Icons.chat_bubble_rounded)),
                    label: ChatStrings.tabChats,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: ManagementStrings.tabMore,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
