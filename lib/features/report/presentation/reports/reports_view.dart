import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/report_views.dart';
import 'reports_cubit.dart';

/// Màn báo cáo dùng chung: cơ sở (quản lý) và cả chuỗi (chủ khách sạn).
class ReportsView extends StatelessWidget {
  const ReportsView({
    super.key,
    required this.scope,
    required this.title,
    this.subtitle,
  });

  final ReportScope scope;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(scope),
      create: (_) => getIt<ReportsCubit>()..start(scope),
      child: _ReportsBody(title: title, subtitle: subtitle),
    );
  }
}

class _ReportsBody extends StatefulWidget {
  const _ReportsBody({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  State<_ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends State<_ReportsBody> with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: ReportTab.values.length, vsync: this)..addListener(_onTabChanged);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    context.read<ReportsCubit>().loadTab(ReportTab.values[_tabs.index]);
  }

  Future<void> _pickCustomRange() async {
    final cubit = context.read<ReportsCubit>();
    final today = DateOnly.today();
    final range = cubit.state.range;
    final end = range.to.isAfter(today) ? today : range.to;
    final start = range.from.isAfter(end) ? end : range.from;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: DateTimeRange(start: start, end: end),
      helpText: ReportStrings.custom,
      saveText: AppStrings.apply,
      cancelText: AppStrings.cancel,
    );
    if (picked != null) cubit.setCustomRange(picked);
  }

  Future<void> _export() async {
    final cubit = context.read<ReportsCubit>();
    final result = await AppAction.run(context, cubit.export);
    if (!result.isSuccess || !mounted) return;
    final file = result.value!;
    final saved = await runAction(
      () => FileSaver.save(bytes: file.bytes, fileName: file.fileName),
    );
    if (!mounted) return;
    if (!saved.isSuccess) {
      AppToast.error(context, saved.error!);
    } else if (saved.value == true) {
      AppToast.success(context, ReportStrings.exported(file.fileName));
    } else {
      AppToast.info(context, ReportStrings.exportCanceled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        return AppPage(
          title: widget.title,
          subtitle: widget.subtitle,
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: AppStrings.exportExcel,
              onPressed: _export,
              icon: const Icon(Icons.file_download_outlined),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: ReportStrings.tabRevenue),
              Tab(text: ReportStrings.tabOccupancy),
              Tab(text: ReportStrings.tabBreakdown),
              Tab(text: ReportStrings.tabPeople),
            ],
          ),
          body: Column(
            children: [
              _RangeBar(
                state: state,
                onPreset: (preset) => preset == ReportPreset.custom
                    ? _pickCustomRange()
                    : cubit.setPreset(preset),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _RevenueTab(state: state, isChain: cubit.scope is ChainReportScope),
                    _OccupancyTab(state: state, isChain: cubit.scope is ChainReportScope),
                    _BreakdownTab(state: state),
                    _PeopleTab(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.state, required this.onPreset});

  final ReportsState state;
  final ValueChanged<ReportPreset> onPreset;

  static String _label(ReportPreset preset) => switch (preset) {
        ReportPreset.last7Days => ReportStrings.last7Days,
        ReportPreset.thisMonth => ReportStrings.thisMonth,
        ReportPreset.lastMonth => ReportStrings.lastMonth,
        ReportPreset.thisYear => ReportStrings.thisYear,
        ReportPreset.custom => ReportStrings.custom,
      };

  @override
  Widget build(BuildContext context) {
    final range = state.range;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChoiceChipBar<ReportPreset>(
              options: ReportPreset.values,
              selected: state.preset,
              labelOf: _label,
              onSelected: onPreset,
            ),
            const Gap(AppSpacing.xs),
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: IconText(
                icon: Icons.date_range_outlined,
                text: ReportStrings.rangeLabel(
                  Fmt.date(range.from),
                  Fmt.date(range.to),
                  range.days,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Khối nội dung theo [LoadState] đặt được bên trong danh sách cuộn.
class _Section<T> extends StatelessWidget {
  const _Section({
    required this.state,
    required this.onRetry,
    required this.builder,
  });

  final LoadState<T> state;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (data != null) {
      return Stack(
        children: [
          builder(data),
          if (state.isLoading)
            const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
        ],
      );
    }
    if (state.isFailure) {
      return AppFailureView.fromState(state, onRetry: onRetry, compact: true);
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: AppLoadingView(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption),
        const Gap(2),
        Text(value, style: AppTextStyles.tabular.weight(FontWeight.w600)),
      ],
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab({required this.state, required this.isChain});

  final ReportsState state;
  final bool isChain;

  static String _granularityLabel(RevenueGranularity granularity) => switch (granularity) {
        RevenueGranularity.day => ReportStrings.byDay,
        RevenueGranularity.week => ReportStrings.byWeek,
        RevenueGranularity.month => ReportStrings.byMonth,
        RevenueGranularity.year => ReportStrings.byYear,
      };

  static String _bucketLabel(RevenueBucket bucket, RevenueGranularity granularity) =>
      switch (granularity) {
        RevenueGranularity.day => Fmt.weekdayDate(bucket.start),
        RevenueGranularity.week =>
          '${ReportStrings.weekLabel(bucket.week ?? 0)} · ${Fmt.dayMonth(bucket.start)} – ${Fmt.dayMonth(bucket.end)}',
        RevenueGranularity.month => Fmt.monthYear(bucket.start.month, bucket.start.year),
        RevenueGranularity.year => '${bucket.start.year}',
      };

  static ChartPoint _point(RevenueBucket bucket, RevenueGranularity granularity) => ChartPoint(
        switch (granularity) {
          RevenueGranularity.day || RevenueGranularity.week => Fmt.dayMonth(bucket.start),
          RevenueGranularity.month => Fmt.monthShort(bucket.start.month),
          RevenueGranularity.year => '${bucket.start.year}',
        },
        bucket.revenue,
        tooltip: _bucketLabel(bucket, granularity),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          ChoiceChipBar<RevenueGranularity>(
            options: RevenueGranularity.values,
            selected: state.granularity,
            labelOf: _granularityLabel,
            onSelected: cubit.setGranularity,
            padding: EdgeInsets.zero,
          ),
          const Gap(AppSpacing.sm),
          _Section<RevenueReport>(
            state: state.revenue,
            onRetry: cubit.refresh,
            builder: (report) {
              final nonEmpty = report.buckets.where((bucket) => bucket.revenue > 0).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(ReportStrings.totalRevenue, style: AppTextStyles.caption),
                        const Gap(4),
                        Text(
                          Fmt.money(report.totalRevenue),
                          style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
                        ),
                        const Gap(AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: ReportStrings.completedBookings,
                                value: Fmt.number(report.totalBookings),
                              ),
                            ),
                            Expanded(
                              child: _MiniStat(
                                label: ReportStrings.averagePerBooking,
                                value: Fmt.money(report.averagePerBooking),
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                        AppBarChart(
                          points: [
                            for (final bucket in report.buckets) _point(bucket, report.granularity),
                          ],
                        ),
                        const Gap(AppSpacing.xs),
                        Text(ReportStrings.revenueNote, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (nonEmpty.isNotEmpty) ...[
                    const Gap(AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionHeader(title: ReportStrings.detailTitle),
                          const Gap(AppSpacing.xs),
                          for (final bucket in nonEmpty)
                            InfoRow(
                              label: _bucketLabel(bucket, report.granularity),
                              value: '',
                              valueWidget: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Fmt.money(bucket.revenue),
                                    style: AppTextStyles.tabular.weight(FontWeight.w600),
                                  ),
                                  Text(
                                    AppStrings.bookingsCount(bucket.bookings),
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (isChain) ...[
            const Gap(AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: ReportStrings.branchComparison,
                    subtitle: ReportStrings.branchComparisonNote(state.range.to.year),
                  ),
                  const Gap(AppSpacing.xs),
                  _Section<List<BranchRevenue>>(
                    state: state.comparison,
                    onRetry: cubit.refresh,
                    builder: (rows) => RankedBarList(
                      items: [
                        for (final row in rows)
                          RankedBar(
                            label: row.hotel.name,
                            value: row.revenue,
                            caption: AppStrings.bookingsCount(row.bookings),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OccupancyTab extends StatelessWidget {
  const _OccupancyTab({required this.state, required this.isChain});

  final ReportsState state;
  final bool isChain;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          _Section<OccupancyReport>(
            state: state.occupancy,
            onRetry: cubit.refresh,
            builder: (report) {
              final summary = report.summary;
              final daily = report.daily;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        PercentRing(
                          percent: summary.rate,
                          size: 116,
                          caption: ReportStrings.occupancyRate,
                        ),
                        const Gap(AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MiniStat(
                                label: ReportStrings.totalRooms,
                                value: Fmt.number(summary.totalRooms),
                              ),
                              const Gap(AppSpacing.sm),
                              _MiniStat(
                                label: ReportStrings.roomNights,
                                value: Fmt.number(summary.roomNights),
                              ),
                              const Gap(AppSpacing.sm),
                              _MiniStat(
                                label: ReportStrings.occupiedNights,
                                value: Fmt.number(summary.occupiedRoomNights),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  Text(ReportStrings.occupancyNote, style: AppTextStyles.caption),
                  const Gap(AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: ReportStrings.dailyOccupancy),
                        const Gap(AppSpacing.md),
                        if (daily == null)
                          Text(
                            isChain
                                ? ReportStrings.dailyOccupancyChainOnly
                                : ReportStrings.dailyOccupancyTooLong,
                            style: AppTextStyles.bodySmall,
                          )
                        else
                          AppLineChart(
                            maxY: 100,
                            axisFormatter: (value) => '${value.round()}%',
                            valueFormatter: Fmt.percent,
                            points: [
                              for (final day in daily)
                                ChartPoint(
                                  Fmt.dayMonth(day.date),
                                  day.rate,
                                  tooltip:
                                      '${Fmt.weekdayDate(day.date)} · ${ReportStrings.roomsOccupied(day.occupiedRooms, day.totalRooms)}',
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BreakdownTab extends StatelessWidget {
  const _BreakdownTab({required this.state});

  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          _Section<BreakdownReport>(
            state: state.breakdown,
            onRetry: cubit.refresh,
            builder: (report) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: ReportStrings.byRoomType),
                      const Gap(AppSpacing.xs),
                      RankedBarList(
                        items: [
                          for (final row in report.roomTypes)
                            RankedBar(
                              label: row.name,
                              value: row.revenue,
                              caption:
                                  '${ReportStrings.bookedRooms(row.bookedRooms)} · ${ReportStrings.nights(row.roomNights)}',
                            ),
                        ],
                      ),
                      const Gap(AppSpacing.xs),
                      Text(ReportStrings.roomTypeNote, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: ReportStrings.byService),
                      const Gap(AppSpacing.xs),
                      RankedBarList(
                        color: AppColors.accent,
                        items: [
                          for (final row in report.services)
                            RankedBar(
                              label: row.name,
                              value: row.revenue,
                              caption: ReportStrings.quantity(row.quantity),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleTab extends StatelessWidget {
  const _PeopleTab({required this.state});

  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          _Section<PeopleReport>(
            state: state.people,
            onRetry: cubit.refresh,
            builder: (report) {
              final cancellation = report.cancellation;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: ReportStrings.cancellation),
                        const Gap(AppSpacing.md),
                        Row(
                          children: [
                            PercentRing(
                              percent: cancellation.rate,
                              size: 104,
                              color: AppColors.danger,
                            ),
                            const Gap(AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _MiniStat(
                                    label: ReportStrings.totalBookings,
                                    value: Fmt.number(cancellation.total),
                                  ),
                                  const Gap(AppSpacing.sm),
                                  _MiniStat(
                                    label: ReportStrings.canceledBookings,
                                    value: Fmt.number(cancellation.canceled),
                                  ),
                                  const Gap(AppSpacing.sm),
                                  _MiniStat(
                                    label: ReportStrings.completedCount,
                                    value: Fmt.number(cancellation.completed),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: ReportStrings.topCustomers),
                        const Gap(AppSpacing.xs),
                        if (report.topCustomers.isEmpty)
                          const _EmptyLine()
                        else
                          for (var i = 0; i < report.topCustomers.length; i++)
                            _PersonRow(
                              rank: i + 1,
                              name: report.topCustomers[i].fullName,
                              detail:
                                  '${report.topCustomers[i].phoneNumber} · ${AppStrings.bookingsCount(report.topCustomers[i].bookings)}',
                              amount: report.topCustomers[i].spend,
                            ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(
                          title: ReportStrings.staffPerformance,
                          subtitle: ReportStrings.staffPerformanceNote,
                        ),
                        const Gap(AppSpacing.xs),
                        if (report.staff.isEmpty)
                          const _EmptyLine()
                        else
                          for (final staff in report.staff)
                            _PersonRow(
                              name: (staff.fullName ?? '').isEmpty ? staff.username : staff.fullName!,
                              detail: [
                                if ((staff.positionName ?? '').isNotEmpty) staff.positionName!,
                                '@${staff.username}',
                                AppStrings.bookingsCount(staff.bookings),
                              ].join(' · '),
                              amount: staff.revenue,
                            ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.name,
    required this.detail,
    required this.amount,
    this.rank,
  });

  final String name;
  final String detail;
  final double amount;

  /// Thứ hạng khi danh sách có thứ tự (khách chi tiêu nhiều nhất).
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final podium = rank != null && rank! <= 3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (rank != null)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: podium ? AppColors.accentSoft : AppColors.surfaceSunk,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: AppTextStyles.captionStrong.colored(
                  podium ? AppColors.warning : AppColors.inkSecondary,
                ),
              ),
            )
          else
            AppAvatar(name: name, size: 32),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(detail, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(Fmt.money(amount), style: AppTextStyles.tabular.weight(FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(ReportStrings.noData, style: AppTextStyles.bodySmall),
    );
  }
}
