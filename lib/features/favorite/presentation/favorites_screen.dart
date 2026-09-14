import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/component/component.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/booking_strings.dart';
import '../../../core/text/explore_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/favorite_hotel.dart';
import 'favorite_button.dart';
import 'favorites_cubit.dart';

@RoutePage()
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState.isGuest) {
          return AppPage(
            title: ExploreStrings.favoritesTitle,
            automaticallyImplyLeading: false,
            body: LoginPromptView(
              title: AuthStrings.loginRequiredTitle,
              message: AuthStrings.loginRequiredFavorites,
              icon: Icons.favorite_border_rounded,
              onLogin: () => context.rootRouter.push<bool>(LoginRoute(returnResult: true)),
              onRegister: () => context.rootRouter.push<bool>(RegisterRoute(returnResult: true)),
            ),
          );
        }
        return BlocBuilder<FavoritesCubit, List<FavoriteHotel>>(
          builder: (context, favorites) => AppPage(
            title: ExploreStrings.favoritesTitle,
            subtitle: favorites.isEmpty ? null : ExploreStrings.branchesCount(favorites.length),
            automaticallyImplyLeading: false,
            body: favorites.isEmpty
                ? AppEmptyView(
                    icon: Icons.favorite_border_rounded,
                    title: ExploreStrings.favoritesEmpty,
                    message: ExploreStrings.favoritesEmptyHint,
                    action: AppButton.secondary(
                      label: BookingStrings.exploreNow,
                      size: AppButtonSize.medium,
                      icon: Icons.travel_explore_rounded,
                      onPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
                    ),
                  )
                : ListView.separated(
                    padding: AppSpacing.page,
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                    itemBuilder: (context, index) => _FavoriteTile(hotel: favorites[index]),
                  ),
          ),
        );
      },
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.hotel});

  final FavoriteHotel hotel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.rootRouter.push(HotelDetailRoute(hotelId: hotel.id)),
      child: Row(
        children: [
          AppNetworkImage(
            path: hotel.pathImage,
            width: 84,
            height: 84,
            borderRadius: AppRadius.smAll,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                const Gap(2),
                IconText(icon: Icons.location_on_outlined, text: hotel.address),
                const Gap(6),
                Row(
                  children: [
                    if (hotel.category.isNotEmpty) ...[
                      SoftTag(label: hotel.category),
                      const Gap(AppSpacing.xs),
                    ],
                    if (hotel.rating > 0) RatingStars(rating: hotel.rating, size: 13),
                  ],
                ),
              ],
            ),
          ),
          FavoriteButton(hotel: hotel, size: 36),
        ],
      ),
    );
  }
}
