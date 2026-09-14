import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/report_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../hotel/domain/entities/hotel.dart';
import '../domain/usecases/hotel_chain_usecases.dart';
import 'chain_cubits.dart';

/// Tab Tổng quan của chủ khách sạn.
@RoutePage()
class ChainOverviewScreen extends StatelessWidget {
  const ChainOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chainId = context.select(
      (SessionCubit cubit) => cubit.state.session?.hotelChain?.id,
    );
    if (chainId == null) return const SizedBox.shrink();
    return BlocProvider(
      key: ValueKey(chainId),
      create: (_) => getIt<ChainOverviewCubit>()..start(chainId),
      child: const _ChainOverviewView(),
    );
  }
}

class _ChainOverviewView extends StatelessWidget {
  const _ChainOverviewView();

  Future<void> _refresh(BuildContext context) async {
    final chainCubit = context.read<ChainCubit>();
    await context.read<ChainOverviewCubit>().load();
    await chainCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChainOverviewCubit, LoadState<ChainOverview>>(
      builder: (context, state) {
        return Scaffold(
          body: LoadStateView<ChainOverview>(
            state: state,
            onRetry: context.read<ChainOverviewCubit>().load,
            builder: (context, overview) => RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: _OverviewBody(
                overview: overview,
                refreshing: state.isLoading,
                onChanged: () => _refresh(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.overview,
    required this.refreshing,
    required this.onChanged,
  });

  final ChainOverview overview;
  final bool refreshing;
  final Future<void> Function() onChanged;

  Future<void> _openBranchForm(BuildContext context, int chainId) async {
    final saved = await context.rootRouter.push<bool>(BranchFormRoute(chainId: chainId));
    if (saved == true) await onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final detail = overview.detail;
    final chain = detail.chain;
    final months = overview.last5Months;
    final current = months.isEmpty ? null : months.last;
    final previous = months.length < 2 ? null : months[months.length - 2];
    final occupancy = overview.occupancy;
    final onDarkMuted = AppColors.onPrimary.withValues(alpha: 0.82);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandMark(size: 44, onDark: true),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Role.hotelOwner.label,
                          style: AppTextStyles.captionStrong.colored(onDarkMuted),
                        ),
                        Text(
                          chain.name,
                          style: AppTextStyles.title.colored(AppColors.onPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (chain.description.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                Text(
                  chain.description,
                  style: AppTextStyles.bodySmall.colored(onDarkMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Gap(AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _HeaderPill(
                    icon: Icons.apartment_rounded,
                    label: ManagementStrings.branchesCount(detail.hotels.length),
                  ),
                  _HeaderPill(
                    icon: Icons.check_circle_outline_rounded,
                    label: ManagementStrings.activeBranches(
                      detail.activeCount,
                      detail.hotels.length,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (refreshing) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatCard(
                        label: ManagementStrings.revenueThisMonth,
                        value: Fmt.moneyCompact(current?.revenue ?? 0),
                        icon: Icons.payments_outlined,
                        tone: StatusTone.success,
                        caption: previous == null
                            ? null
                            : WorkspaceStrings.previousMonth(
                                Fmt.moneyCompact(previous.revenue),
                              ),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: StatCard(
                        label: ManagementStrings.chainOccupancy,
                        value: occupancy == null ? '–' : Fmt.percent(occupancy.rate),
                        icon: Icons.bed_outlined,
                        tone: StatusTone.info,
                        caption: occupancy == null
                            ? WorkspaceStrings.noReportData
                            : WorkspaceStrings.occupiedOf(
                                occupancy.occupiedRoomNights,
                                occupancy.roomNights,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: ManagementStrings.chainRevenue5Months),
                    const Gap(AppSpacing.md),
                    AppBarChart(
                      height: 200,
                      highlightLast: true,
                      points: [
                        for (final month in months)
                          ChartPoint(
                            Fmt.monthShort(month.month),
                            month.revenue,
                            tooltip: Fmt.monthYear(month.month, month.year),
                          ),
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Text(ReportStrings.revenueNote, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Gap(AppSpacing.lg),
              SectionHeader(
                title: ManagementStrings.branchesSection,
                actionLabel: AppStrings.seeAll,
                onAction: () => AutoTabsRouter.of(context).setActiveIndex(1),
              ),
              const Gap(AppSpacing.sm),
              if (detail.hotels.isEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(ManagementStrings.branchesEmpty, style: AppTextStyles.subtitle),
                      const Gap(4),
                      Text(ManagementStrings.branchesEmptyHint, style: AppTextStyles.bodySmall),
                      const Gap(AppSpacing.md),
                      AppButton(
                        label: ManagementStrings.openBranch,
                        icon: Icons.add_business_rounded,
                        onPressed: () => _openBranchForm(context, chain.id),
                      ),
                    ],
                  ),
                )
              else
                for (final hotel in detail.hotels) ...[
                  _BranchRow(
                    hotel: hotel,
                    onOpen: () => context.rootRouter.push(WorkspaceShellRoute(hotelId: hotel.id)),
                  ),
                  const Gap(AppSpacing.xs),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onPrimary),
          const Gap(6),
          Text(label, style: AppTextStyles.captionStrong.colored(AppColors.onPrimary)),
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({required this.hotel, required this.onOpen});

  final Hotel hotel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppNetworkImage(
            path: hotel.pathImage,
            width: 56,
            height: 56,
            borderRadius: AppRadius.smAll,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                IconText(icon: Icons.location_on_outlined, text: hotel.address),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          StatusBadge(
            dense: true,
            label: hotel.active ? WorkspaceStrings.branchActive : WorkspaceStrings.branchInactive,
            tone: hotel.active ? StatusTone.success : StatusTone.neutral,
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
        ],
      ),
    );
  }
}
