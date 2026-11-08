import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/text/chat_strings.dart';
import '../../../core/text/explore_strings.dart';
import '../../chat/presentation/chat_entry.dart';
import '../../../core/text/discover_strings.dart';

/// Vị trí các tab của khách, dùng thay cho số khi chuyển tab.
abstract final class CustomerTabs {
  static const home = 0;
  static const hotels = 1;
  static const bookings = 2;
  static const favorites = 3;
  static const chats = 4;
  static const account = 5;
}

/// Khung cho khách vãng lai và khách hàng: 6 tab dưới đáy, tour (Trang chủ) trước, khách sạn sau.
@RoutePage()
class CustomerShellScreen extends StatelessWidget {
  const CustomerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        TourHomeRoute(),
        ExploreRoute(),
        MyBookingsRoute(),
        FavoritesRoute(),
        ChatInboxRoute(),
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
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: DiscoverStrings.tabHome,
                ),
                NavigationDestination(
                  icon: Icon(Icons.apartment_outlined),
                  selectedIcon: Icon(Icons.apartment_rounded),
                  label: DiscoverStrings.tabHotels,
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
                  icon: ChatBadge(child: Icon(Icons.chat_bubble_outline_rounded)),
                  selectedIcon: ChatBadge(child: Icon(Icons.chat_bubble_rounded)),
                  label: ChatStrings.tabChats,
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
