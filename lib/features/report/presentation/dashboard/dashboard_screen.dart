import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/presentation/desk/desk_cubit.dart';
import '../../../booking/presentation/widgets/booking_card.dart';
import '../../../shell/presentation/workspace_scope.dart';
import '../../domain/entities/report_views.dart';
import '../../domain/usecases/report_usecases.dart';

@injectable
class DashboardCubit extends LoadCubit<BranchDashboard> {
  DashboardCubit(this._loadDashboard);

  final LoadBranchDashboard _loadDashboard;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _loadDashboard(_hotelId));
}

/// Tab Tổng quan của quản lý: việc hôm nay, số liệu tháng, khách sắp đến.
@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelId = WorkspaceScope.of(context).hotelId;
    return BlocProvider(
      key: ValueKey(hotelId),
      create: (_) => getIt<DashboardCubit>()..start(hotelId),
      child: _DashboardView(hotelId: hotelId),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    final branchName = context.branchName;
    return BlocBuilder<DashboardCubit, LoadState<BranchDashboard>>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        return AppPage(
          title: WorkspaceStrings.tabDashboard,
          subtitle: branchName,
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: LoadStateView<BranchDashboard>(
            state: state,
            onRetry: cubit.load,
            builder: (context, data) => RefreshIndicator(
              onRefresh: cubit.load,
              child: _DashboardBody(data: data, hotelId: hotelId),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.hotelId});

  final BranchDashboard data;
  final int hotelId;

  /// Tab Quầy đứng thứ hai trong thanh điều hướng của quản lý.
  void _openDesk(BuildContext context) => AutoTabsRouter.of(context).setActiveIndex(1);

  Future<void> _openBooking(BuildContext context, Booking booking) async {
    await context.rootRouter.push(BookingDetailRoute(bookingId: booking.id));
    if (context.mounted) await context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateOnly.today();
    final months = data.last5Months;
    final current = data.currentMonth;
    final previous = data.previousMonth;
    final occupancy = data.occupancy;
    final cancellation = data.cancellation;
    int countOf(DeskFilter filter) => data.bookings
        .where((booking) => DeskState.matchesFilter(booking, filter, today))
        .length;
    final upcoming = data.bookings
        .where((booking) => booking.status.isOpen && !booking.checkinDate.isBefore(today))
        .toList()
      ..sort((a, b) => a.checkinDate.compareTo(b.checkinDate));

    return ListView(
      padding: AppSpacing.page,
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(WorkspaceStrings.today, style: AppTextStyles.subtitle),
                  const Gap(AppSpacing.xs),
                  Text(
                    '${Fmt.weekdayLong(today)}, ${Fmt.date(today)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Gap(AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: _TodayCounter(
                      label: WorkspaceStrings.arrivals,
                      value: countOf(DeskFilter.arrivals),
                      icon: Icons.login_rounded,
                      tone: StatusTone.info,
                      onTap: () => _openDesk(context),
                    ),
                  ),
                  Expanded(
                    child: _TodayCounter(
                      label: WorkspaceStrings.departures,
                      value: countOf(DeskFilter.departures),
                      icon: Icons.logout_rounded,
                      tone: StatusTone.brand,
                      onTap: () => _openDesk(context),
                    ),
                  ),
                  Expanded(
                    child: _TodayCounter(
                      label: WorkspaceStrings.pending,
                      value: countOf(DeskFilter.pending),
                      icon: Icons.hourglass_top_rounded,
                      tone: StatusTone.warning,
                      onTap: () => _openDesk(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: WorkspaceStrings.kpiRevenue,
                  value: Fmt.moneyCompact(current?.revenue ?? 0),
                  icon: Icons.payments_outlined,
                  tone: StatusTone.success,
                  caption: previous == null
                      ? null
                      : WorkspaceStrings.previousMonth(Fmt.moneyCompact(previous.revenue)),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: WorkspaceStrings.kpiCompleted,
                  value: Fmt.number(current?.bookings ?? 0),
                  icon: Icons.task_alt_rounded,
                  caption: previous == null
                      ? null
                      : WorkspaceStrings.previousMonth(Fmt.number(previous.bookings)),
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: WorkspaceStrings.kpiOccupancy,
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
              const Gap(AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: WorkspaceStrings.kpiCancellation,
                  value: cancellation == null ? '–' : Fmt.percent(cancellation.rate),
                  icon: Icons.event_busy_outlined,
                  tone: StatusTone.danger,
                  caption: cancellation == null
                      ? WorkspaceStrings.noReportData
                      : WorkspaceStrings.canceledOf(cancellation.canceled, cancellation.total),
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: WorkspaceStrings.revenue5Months),
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
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        SectionHeader(
          title: WorkspaceStrings.upcomingArrivals,
          actionLabel: AppStrings.seeAll,
          onAction: () => _openDesk(context),
        ),
        const Gap(AppSpacing.sm),
        if (upcoming.isEmpty)
          const AppCard(
            child: IconText(
              icon: Icons.event_available_outlined,
              text: WorkspaceStrings.noUpcoming,
            ),
          )
        else
          for (final booking in upcoming.take(5)) ...[
            BookingCard(
              booking: booking,
              view: BookingCardView.desk,
              onTap: () => _openBooking(context, booking),
            ),
            const Gap(AppSpacing.sm),
          ],
        const Gap(AppSpacing.md),
        const SectionHeader(title: WorkspaceStrings.quickActions),
        const Gap(AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton.tonal(
                label: BookingStrings.walkInAction,
                icon: Icons.add_business_outlined,
                size: AppButtonSize.medium,
                onPressed: () => context.rootRouter.push(WalkInBookingRoute(hotelId: hotelId)),
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: AppButton.secondary(
                label: WorkspaceStrings.addRoom,
                icon: Icons.bed_outlined,
                size: AppButtonSize.medium,
                onPressed: () => context.rootRouter.push(RoomFormRoute(hotelId: hotelId)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayCounter extends StatelessWidget {
  const _TodayCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final StatusTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: colors.foreground),
            ),
            const Gap(6),
            Text('$value', style: AppTextStyles.metric.copyWith(fontSize: 20)),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
