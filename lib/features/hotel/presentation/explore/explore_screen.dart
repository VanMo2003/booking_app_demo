import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../ai/presentation/ai_widgets.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../widgets/hotel_card.dart';
import 'explore_cubit.dart';

/// Trang chủ: ai cũng xem được, không cần đăng nhập.
@RoutePage()
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExploreCubit>()..load(),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView();

  void _openHotel(BuildContext context, int hotelId) {
    context.rootRouter.push(HotelDetailRoute(hotelId: hotelId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        final cubit = context.read<ExploreCubit>();
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >
                    notification.metrics.maxScrollExtent - 400) {
                  cubit.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _ExploreHeader(state: state)),
                  if (state.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: ChoiceChipBar<String?>(
                          options: [null, ...state.categories],
                          selected: state.category,
                          labelOf: (option) => option ?? AppStrings.all,
                          onSelected: cubit.selectCategory,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: state.category ?? ExploreStrings.allBranches,
                        subtitle: state.status == ViewStatus.success
                            ? ExploreStrings.branchesCount(state.hotels.length)
                            : null,
                      ),
                    ),
                  ),
                  ..._content(context, state, cubit),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.xl)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(BuildContext context, ExploreState state, ExploreCubit cubit) {
    if (state.hotels.isEmpty) {
      final Widget child = switch (state.status) {
        ViewStatus.failure => AppFailureView(
            message: state.error!,
            kind: state.errorKind,
            onRetry: cubit.load,
          ),
        ViewStatus.success => AppEmptyView(
            icon: Icons.apartment_rounded,
            title: state.category == null
                ? ExploreStrings.branchesEmpty
                : ExploreStrings.branchesEmptyCategory,
          ),
        _ => const AppLoadingView(),
      };
      return [SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 24), child: child))];
    }
    return [
      SliverPadding(
        padding: AppSpacing.pageHorizontal,
        sliver: SliverList.separated(
          itemCount: state.hotels.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.md),
          itemBuilder: (context, index) {
            final hotel = state.hotels[index];
            return HotelCard(hotel: hotel, onTap: () => _openHotel(context, hotel.id));
          },
        ),
      ),
      if (state.loadingMore)
        const SliverToBoxAdapter(child: AppLoadingView()),
    ];
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.state});

  final ExploreState state;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: topInset + 196,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 180,
                height: 180,
                margin: const EdgeInsets.only(top: 0, right: 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.onPrimary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GreetingRow(),
                const Gap(AppSpacing.sm),
                Text(
                  ExploreStrings.homeHeadline,
                  style: AppTextStyles.headline.colored(AppColors.onPrimary),
                ),
                const Gap(AppSpacing.lg),
                AppCard(
                  elevated: true,
                  radius: AppRadius.lg,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StayDatesCard(
                        checkin: state.checkin,
                        checkout: state.checkout,
                        onChanged: context.read<ExploreCubit>().setDates,
                      ),
                      const Gap(AppSpacing.sm),
                      AppButton(
                        label: ExploreStrings.findAvailable,
                        icon: Icons.search_rounded,
                        onPressed: () => context.rootRouter.push(
                          SearchResultsRoute(
                            checkin: state.checkin,
                            checkout: state.checkout,
                          ),
                        ),
                      ),
                      const AiSearchEntry(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        final session = sessionState.session;
        return Row(
          children: [
            Expanded(
              child: Text(
                session == null
                    ? ExploreStrings.greetingGuest
                    : ExploreStrings.greetingName(session.displayName),
                style: AppTextStyles.bodyMedium.colored(
                  AppColors.onPrimary.withValues(alpha: 0.85),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (session == null)
              TextButton.icon(
                onPressed: () =>
                    context.rootRouter.push<bool>(LoginRoute(returnResult: true)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onPrimary,
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.16),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text(AppStrings.login),
              )
            else
              GestureDetector(
                onTap: () => AutoTabsRouter.of(context).setActiveIndex(4),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                  child: AppAvatar(name: session.displayName, size: 36),
                ),
              ),
          ],
        );
      },
    );
  }
}
