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
import '../../../../core/text/discover_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../voucher/presentation/voucher_widgets.dart';
import '../../domain/entities/tour.dart';
import '../widgets/tour_card.dart';
import '../widgets/tour_discover_widgets.dart';
import 'discover_cubits.dart';
import '../../data/interest_store.dart';

/// Tab đầu của khách: tìm tour theo điểm đến, điểm đến gợi ý, mã giảm giá, tour nổi bật, khuyến mãi và gợi ý
/// theo sở thích.
@RoutePage()
class TourHomeScreen extends StatefulWidget {
  const TourHomeScreen({super.key});

  @override
  State<TourHomeScreen> createState() => _TourHomeScreenState();
}

class _TourHomeScreenState extends State<TourHomeScreen> {
  final _cubit = getIt<TourHomeCubit>();

  @override
  void initState() {
    super.initState();
    final store = getIt<InterestStore>();
    if (store.asked) {
      _cubit.load();
      // Khách vừa đăng nhập: đưa sở thích chọn trên máy lên hồ sơ (lỗi thì thôi).
      if (store.interests.isNotEmpty) store.push();
    } else {
      // Lần đầu mở app: hỏi sở thích trước khi gợi ý.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await context.rootRouter.push(InterestsRoute(onboarding: true));
        await _cubit.load();
      });
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: const _TourHomeView());
  }
}

class _TourHomeView extends StatelessWidget {
  const _TourHomeView();

  void _openTour(BuildContext context, Tour tour) {
    context.rootRouter.push(TourDetailRoute(tour: tour, hotelName: tour.hotelName));
  }

  Future<void> _editInterests(BuildContext context) async {
    final changed = await context.rootRouter.push<bool>(InterestsRoute());
    if (changed == true && context.mounted) await context.read<TourHomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TourHomeCubit>();
    return Scaffold(
      body: BlocBuilder<TourHomeCubit, LoadState<TourHomeView>>(
        builder: (context, state) {
          final view = state.data;
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _Header(onSearch: () => context.rootRouter.push(TourSearchRoute()))),
                if (view == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: state.isFailure
                          ? AppFailureView.fromState(state, onRetry: cubit.load)
                          : const AppLoadingView(),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _InterestsRow(view: view, onEdit: () => _editInterests(context)),
                  ),
                  if (view.home.destinations.isNotEmpty) ...[
                    const _Title(DiscoverStrings.destinations),
                    SliverToBoxAdapter(
                      child: _Shelf(
                        height: 128,
                        children: [
                          for (final place in view.home.destinations)
                            _DestinationCard(
                              destination: place,
                              onTap: () => context.rootRouter.push(TourSearchRoute(query: place.name)),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (view.vouchers.isNotEmpty) ...[
                    const _Title(DiscoverStrings.vouchers),
                    SliverToBoxAdapter(
                      child: _Shelf(
                        height: 124,
                        children: [
                          for (final voucher in view.vouchers) VoucherTicket(voucher: voucher, width: 260),
                        ],
                      ),
                    ),
                  ],
                  if (view.home.featured.isNotEmpty) ...[
                    const _Title(DiscoverStrings.featured),
                    SliverToBoxAdapter(child: _TourShelf(tours: view.home.featured, onTap: _openTour)),
                  ],
                  if (view.home.deals.isNotEmpty) ...[
                    const _Title(DiscoverStrings.deals),
                    SliverToBoxAdapter(child: _TourShelf(tours: view.home.deals, onTap: _openTour)),
                  ],
                  if (view.interests.isNotEmpty) ...[
                    _Title(
                      DiscoverStrings.forYou,
                      subtitle: DiscoverStrings.forYouNote(view.interests.map((t) => t.label).join(', ')),
                    ),
                    SliverPadding(
                      padding: AppSpacing.pageHorizontal,
                      sliver: SliverList.separated(
                        itemCount: view.home.forYou.length,
                        separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                        itemBuilder: (context, i) => TourCard(
                          tour: view.home.forYou[i],
                          onTap: () => _openTour(context, view.home.forYou[i]),
                        ),
                      ),
                    ),
                  ],
                  if (view.home.featured.isEmpty && view.home.destinations.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: AppEmptyView(icon: Icons.tour_outlined, title: DiscoverStrings.homeEmpty),
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: Gap(AppSpacing.xl)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(DiscoverStrings.homeHeadline, style: AppTextStyles.headline.colored(AppColors.onPrimary)),
              const Gap(AppSpacing.md),
              Material(
                color: AppColors.surface,
                borderRadius: AppRadius.mdAll,
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: onSearch,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.inkSecondary),
                        Gap(AppSpacing.sm),
                        Expanded(
                          child: Text(
                            DiscoverStrings.searchHint,
                            style: TextStyle(color: AppColors.inkTertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestsRow extends StatelessWidget {
  const _InterestsRow({required this.view, required this.onEdit});

  final TourHomeView view;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (view.interests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: AppCard(
          onTap: onEdit,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              const Gap(AppSpacing.sm),
              Expanded(child: Text(DiscoverStrings.pickInterests, style: AppTextStyles.bodySmall)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        children: [
          for (final theme in view.interests) ...[
            Chip(avatar: Icon(theme.icon, size: 16), label: Text(theme.label), visualDensity: VisualDensity.compact),
            const Gap(6),
          ],
          ActionChip(
            avatar: const Icon(Icons.tune_rounded, size: 16),
            label: const Text(DiscoverStrings.interestsEdit),
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      sliver: SliverToBoxAdapter(child: SectionHeader(title: title, subtitle: subtitle)),
    );
  }
}

/// Dải cuộn ngang có lề trang hai bên.
class _Shelf extends StatelessWidget {
  const _Shelf({required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageHorizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

class _TourShelf extends StatelessWidget {
  const _TourShelf({required this.tours, required this.onTap});

  final List<Tour> tours;
  final void Function(BuildContext context, Tour tour) onTap;

  @override
  Widget build(BuildContext context) {
    return _Shelf(
      height: 300,
      children: [for (final tour in tours) TourShelfCard(tour: tour, onTap: () => onTap(context, tour))],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination, required this.onTap});

  final TourDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(path: destination.pathImage, placeholderIcon: Icons.landscape_rounded),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: AppTextStyles.bodyStrong.colored(AppColors.onPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${DiscoverStrings.destinationTours(destination.tours)} · '
                        '${DiscoverStrings.fromPrice(Fmt.moneyCompact(destination.fromPrice))}',
                        style: AppTextStyles.caption.colored(AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
