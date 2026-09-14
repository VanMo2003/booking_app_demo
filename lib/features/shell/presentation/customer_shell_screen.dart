import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/explore_strings.dart';

/// Khung cho khách vãng lai và khách hàng: 4 tab dưới đáy.
@RoutePage()
class CustomerShellScreen extends StatelessWidget {
  const CustomerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        ExploreRoute(),
        MyBookingsRoute(),
        FavoritesRoute(),
        AccountRoute(),
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
                  icon: Icon(Icons.travel_explore_outlined),
                  selectedIcon: Icon(Icons.travel_explore_rounded),
                  label: ExploreStrings.tabExplore,
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: ExploreStrings.tabBookings,
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: ExploreStrings.tabFavorites,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: ExploreStrings.tabAccount,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
