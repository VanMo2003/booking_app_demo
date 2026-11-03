import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/report_views.dart';
import '../widgets/growth_text.dart';
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
    final report = state.revenue.data;
    // một tháng trống năm nay nhưng có doanh thu năm trước vẫn đáng xem
    final nonEmpty = report?.buckets
            .where((bucket) => bucket.revenue > 0 || (bucket.previousRevenue ?? 0) > 0)
            .toList() ??
        const [];
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          _Section<RevenueSummary>(
            state: state.summary,
            onRetry: cubit.refresh,
            builder: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryCard(summary: summary),
                const Gap(AppSpacing.md),
                _SharesCard(summary: summary),
              ],
            ),
          ),
          if (isChain) ...[
            const Gap(AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: ReportStrings.branchComparison,
                    subtitle: ReportStrings.branchComparisonNote,
                  ),
                  const Gap(AppSpacing.sm),
                  _Section<List<BranchPerformance>>(
                    state: state.comparison,
                    onRetry: cubit.refresh,
                    builder: (rows) => _BranchComparison(rows: rows),
                  ),
                ],
              ),
            ),
          ],
          const Gap(AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: ReportStrings.trendTitle,
                  subtitle: ReportStrings.trendNote,
                ),
                const Gap(AppSpacing.sm),
                ChoiceChipBar<RevenueGranularity>(
                  options: RevenueGranularity.values,
                  selected: state.granularity,
                  labelOf: _granularityLabel,
                  onSelected: cubit.setGranularity,
                  padding: EdgeInsets.zero,
                ),
                const Gap(AppSpacing.md),
                _Section<RevenueReport>(
                  state: state.revenue,
                  onRetry: cubit.refresh,
                  builder: (report) => AppBarChart(
                    points: [
                      for (final bucket in report.buckets) _point(bucket, report.granularity),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (report != null && nonEmpty.isNotEmpty) ...[
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
                            ReportStrings.bucketCounts(AppStrings.bookingsCount(bucket.bookings), bucket.tours),
                            style: AppTextStyles.caption,
                          ),
                          if (bucket.previousRevenue != null)
                            Text(
                              ReportStrings.yearOverYear(
                                Fmt.moneyCompact(bucket.previousRevenue),
                                bucket.yearOverYear == null ? null : signedPercent(bucket.yearOverYear!),
                              ),
                              style: AppTextStyles.caption.colored(
                                (bucket.yearOverYear ?? 0) < 0 ? AppColors.danger : AppColors.inkSecondary,
                              ),
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

/// Tổng doanh thu kỳ (gồm tour), cơ cấu phòng / dịch vụ / tour và các KPI
/// buồng phòng, mỗi số kèm mức tăng giảm so với kỳ trước.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final RevenueSummary summary;

  @override
  Widget build(BuildContext context) {
    final current = summary.current;
    final previous = summary.previous;
    final parts = <_Part>[
      (
        label: ReportStrings.roomRevenue,
        detail: ReportStrings.soldNights(current.roomNightsSold),
        value: current.roomRevenue,
        color: AppColors.primary,
      ),
      (
        label: ReportStrings.serviceRevenue,
        detail: null,
        value: current.serviceRevenue,
        color: AppColors.accent,
      ),
      (
        label: ReportStrings.tourRevenue,
        detail: ReportStrings.tourOrders(current.completedTours, current.tourGuests),
        value: current.tourRevenue,
        color: AppColors.info,
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ReportStrings.totalRevenue, style: AppTextStyles.caption),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Fmt.money(current.totalRevenue),
                    style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              _Delta(value: summary.revenueGrowth, pill: true),
            ],
          ),
          const Gap(2),
          Text(
            ReportStrings.previousPeriod(
              Fmt.date(previous.from),
              Fmt.date(previous.to),
              Fmt.money(previous.totalRevenue),
            ),
            style: AppTextStyles.caption,
          ),
          const Gap(AppSpacing.md),
          _CompositionBar(parts: parts),
          const Gap(AppSpacing.sm),
          for (final part in parts) _LegendRow(part: part, total: current.totalRevenue),
          const Gap(AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kpi(
                  label: ReportStrings.grossProfit,
                  value: Fmt.money(current.grossProfit),
                  delta: summary.profitGrowth,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _Kpi(
                  label: ReportStrings.payrollCost,
                  value: Fmt.money(current.payrollCost),
                  note: ReportStrings.profitMargin(Fmt.percent(current.profitMargin)),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          const Divider(height: 1, color: AppColors.lineSoft),
          const Gap(AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kpi(
                  label: ReportStrings.adr,
                  value: Fmt.money(current.adr),
                  delta: summary.adrGrowth,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _Kpi(
                  label: ReportStrings.revpar,
                  value: Fmt.money(current.revpar),
                  delta: summary.revparGrowth,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kpi(
                  label: ReportStrings.occupancyShort,
                  value: Fmt.percent(current.occupancyRate),
                  // lấp đầy so theo điểm phần trăm; kỳ trước chưa có phòng thì không so
                  delta: previous.availableRoomNights == 0 ? null : summary.occupancyChange,
                  points: true,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _Kpi(
                  label: ReportStrings.completedBookings,
                  value: Fmt.number(current.completedBookings),
                  delta: summary.bookingGrowth,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kpi(
                  label: ReportStrings.averageStay,
                  value: ReportStrings.nightsDecimal(Fmt.decimal(current.averageStayNights)),
                  note: ReportStrings.previousValue(
                    ReportStrings.nightsDecimal(Fmt.decimal(previous.averageStayNights)),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _Kpi(
                  label: ReportStrings.averageLead,
                  value: ReportStrings.daysDecimal(Fmt.decimal(current.averageLeadDays)),
                  note: ReportStrings.previousValue(
                    ReportStrings.daysDecimal(Fmt.decimal(previous.averageLeadDays)),
                  ),
                ),
              ),
            ],
          ),
          if (current.completedBookings > 0) ...[
            const Gap(AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Kpi(
                    label: ReportStrings.serviceAttach,
                    value: Fmt.percent(current.serviceAttachRate),
                    // so theo điểm phần trăm như lấp đầy
                    delta: previous.completedBookings == 0
                        ? null
                        : current.serviceAttachRate - previous.serviceAttachRate,
                    points: true,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: _Kpi(
                    label: ReportStrings.servicePerBooking,
                    value: Fmt.money(current.servicePerBooking),
                    note: ReportStrings.previousValue(Fmt.money(previous.servicePerBooking)),
                  ),
                ),
              ],
            ),
          ],
          if (current.canceledBookings > 0) ...[
            const Gap(AppSpacing.md),
            IconText(
              icon: Icons.event_busy_outlined,
              text: ReportStrings.canceledLoss(
                current.canceledBookings,
                current.totalBookings,
                Fmt.money(current.canceledRevenue),
              ),
            ),
          ],
          const Gap(AppSpacing.md),
          Text(ReportStrings.summaryNote, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

typedef _Part = ({String label, String? detail, double value, Color color});

/// Thanh ngang chia theo tỷ trọng từng phần doanh thu.
class _CompositionBar extends StatelessWidget {
  const _CompositionBar({required this.parts});

  final List<_Part> parts;

  @override
  Widget build(BuildContext context) {
    final total = parts.fold<double>(0, (sum, part) => sum + part.value);
    return ClipRRect(
      borderRadius: AppRadius.smAll,
      child: SizedBox(
        height: 10,
        child: total <= 0
            ? const ColoredBox(color: AppColors.surfaceSunk)
            : Row(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final part in parts)
                    if (part.value > 0)
                      Expanded(
                        flex: math.max(1, (part.value / total * 1000).round()),
                        child: ColoredBox(color: part.color),
                      ),
                ],
              ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.part, required this.total});

  final _Part part;
  final double total;

  @override
  Widget build(BuildContext context) {
    final share = total <= 0 ? 0.0 : part.value / total * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: part.color, borderRadius: BorderRadius.circular(3)),
          ),
          const Gap(AppSpacing.sm),
          // chi tiết xuống dòng riêng: chung một dòng thì bị cắt ở khổ điện thoại
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.label, style: AppTextStyles.bodySmall),
                if (part.detail != null) Text(part.detail!, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(Fmt.money(part.value), style: AppTextStyles.tabular.weight(FontWeight.w600)),
          SizedBox(
            width: 52,
            child: Text(
              Fmt.percent(share),
              textAlign: TextAlign.right,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    this.delta,
    this.points = false,
    this.note,
  });

  final String label;
  final String value;
  final double? delta;

  /// Dòng phụ thay cho mức tăng giảm, ví dụ giá trị kỳ trước.
  final String? note;

  /// Chênh lệch tính bằng điểm phần trăm (lấp đầy) thay vì phần trăm thay đổi.
  final bool points;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const Gap(2),
        Text(value, style: AppTextStyles.tabular.weight(FontWeight.w600)),
        const Gap(2),
        if (note != null)
          Text(note!, style: AppTextStyles.caption)
        else
          _Delta(value: delta, points: points),
      ],
    );
  }
}

/// Mức tăng giảm so với kỳ trước: xanh khi tăng, đỏ khi giảm.
class _Delta extends StatelessWidget {
  const _Delta({required this.value, this.points = false, this.pill = false});

  final double? value;
  final bool points;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final delta = value;
    if (delta == null) {
      return Text(ReportStrings.noComparison, style: AppTextStyles.caption);
    }
    final tone = delta > 0
        ? StatusTone.success
        : delta < 0
            ? StatusTone.danger
            : StatusTone.neutral;
    final colors = tone.colors;
    final sign = delta > 0
        ? '+'
        : delta < 0
            ? '−'
            : '';
    final magnitude = Fmt.decimal(delta.abs());
    final text = points
        ? ReportStrings.pointDelta(sign, magnitude)
        : ReportStrings.percentDelta(sign, magnitude);
    final icon = delta > 0
        ? Icons.arrow_upward_rounded
        : delta < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.foreground),
        const Gap(2),
        Text(text, style: AppTextStyles.captionStrong.colored(colors.foreground)),
      ],
    );
    if (!pill) return content;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.smAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: content,
      ),
    );
  }
}

/// Doanh thu chia theo phương thức thanh toán và theo kênh bán.
class _SharesCard extends StatelessWidget {
  const _SharesCard({required this.summary});

  final RevenueSummary summary;

  static String _channelLabel(String key) => switch (key) {
        'SELF_SERVICE' => ReportStrings.channelSelfService,
        'FRONT_DESK' => ReportStrings.channelFrontDesk,
        _ => ReportStrings.channelTour,
      };

  static RankedBar _bar(RevenueShare share, String label) => RankedBar(
        label: label,
        value: share.revenue,
        caption: ReportStrings.shareCaption(share.count, Fmt.percent(share.share)),
      );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: ReportStrings.byPaymentMethod,
            subtitle: ReportStrings.byPaymentMethodNote,
          ),
          const Gap(AppSpacing.xs),
          RankedBarList(
            items: [
              for (final share in summary.byPaymentMethod)
                _bar(share, PaymentMethod.parse(share.key).label),
            ],
          ),
          const Gap(AppSpacing.md),
          const SectionHeader(title: ReportStrings.byChannel),
          const Gap(AppSpacing.xs),
          RankedBarList(
            color: AppColors.accent,
            items: [
              for (final share in summary.byChannel) _bar(share, _channelLabel(share.key)),
            ],
          ),
          if (summary.byCustomerType.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            const SectionHeader(
              title: ReportStrings.byCustomerType,
              subtitle: ReportStrings.byCustomerTypeNote,
            ),
            const Gap(AppSpacing.xs),
            RankedBarList(
              color: AppColors.info,
              items: [
                for (final share in summary.byCustomerType)
                  _bar(
                    share,
                    share.key == 'RETURNING' ? ReportStrings.returningGuests : ReportStrings.newGuests,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum _BranchMetric { revenue, profit, growth, occupancy, revpar }

/// Bảng xếp hạng cơ sở của chuỗi, chọn chỉ số để xếp.
class _BranchComparison extends StatefulWidget {
  const _BranchComparison({required this.rows});

  final List<BranchPerformance> rows;

  @override
  State<_BranchComparison> createState() => _BranchComparisonState();
}

class _BranchComparisonState extends State<_BranchComparison> {
  _BranchMetric _metric = _BranchMetric.revenue;

  static String _label(_BranchMetric metric) => switch (metric) {
        _BranchMetric.revenue => ReportStrings.sortRevenue,
        _BranchMetric.profit => ReportStrings.sortProfit,
        _BranchMetric.growth => ReportStrings.sortGrowth,
        _BranchMetric.occupancy => ReportStrings.sortOccupancy,
        _BranchMetric.revpar => ReportStrings.sortRevpar,
      };

  /// Cơ sở chưa có kỳ trước để so xếp cuối khi xem theo tăng trưởng.
  double _sortValue(BranchPerformance branch) => switch (_metric) {
        _BranchMetric.revenue => branch.current.totalRevenue,
        _BranchMetric.profit => branch.current.grossProfit,
        _BranchMetric.growth => branch.revenueGrowth ?? double.negativeInfinity,
        _BranchMetric.occupancy => branch.current.occupancyRate,
        _BranchMetric.revpar => branch.current.revpar,
      };

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) return const _EmptyLine();
    final sorted = [...widget.rows]..sort((a, b) => _sortValue(b).compareTo(_sortValue(a)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceChipBar<_BranchMetric>(
          options: _BranchMetric.values,
          selected: _metric,
          labelOf: _label,
          onSelected: (metric) => setState(() => _metric = metric),
          padding: EdgeInsets.zero,
        ),
        const Gap(AppSpacing.xs),
        for (var i = 0; i < sorted.length; i++)
          InkWell(
            borderRadius: AppRadius.smAll,
            onTap: () => context.rootRouter.push(
              BranchReportDetailRoute(hotelId: sorted[i].hotelId, hotelName: sorted[i].hotelName),
            ),
            child: _BranchRow(rank: i + 1, branch: sorted[i], metric: _metric),
          ),
      ],
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({required this.rank, required this.branch, required this.metric});

  final int rank;
  final BranchPerformance branch;
  final _BranchMetric metric;

  @override
  Widget build(BuildContext context) {
    final current = branch.current;
    final podium = rank <= 3;
    final headline = switch (metric) {
      _BranchMetric.revenue || _BranchMetric.growth => Fmt.money(current.totalRevenue),
      _BranchMetric.profit => Fmt.money(current.grossProfit),
      _BranchMetric.occupancy => Fmt.percent(current.occupancyRate),
      _BranchMetric.revpar => Fmt.money(current.revpar),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        branch.hotelName,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(headline, style: AppTextStyles.tabular.weight(FontWeight.w600)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inkTertiary),
                  ],
                ),
                const Gap(6),
                ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: LinearProgressIndicator(
                    value: (branch.revenueShare / 100).clamp(0, 1),
                    minHeight: 6,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceSunk,
                  ),
                ),
                const Gap(6),
                Text(
                  ReportStrings.branchCaption(
                    Fmt.percent(branch.revenueShare),
                    Fmt.percent(current.occupancyRate),
                    Fmt.moneyCompact(current.adr),
                    Fmt.percent(current.cancellationRate),
                  ),
                  style: AppTextStyles.caption,
                ),
                if (branch.averageRating != null) ...[
                  const Gap(2),
                  Text(
                    ReportStrings.branchRating(Fmt.decimal(branch.averageRating), branch.reviews),
                    style: AppTextStyles.caption,
                  ),
                ],
                const Gap(2),
                _Delta(value: branch.revenueGrowth),
              ],
            ),
          ),
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
                  if (report.weekdays.any((day) => day.days > 0)) ...[
                    const Gap(AppSpacing.md),
                    _WeekdaysCard(weekdays: report.weekdays),
                  ],
                  if (report.rooms != null) ...[
                    const Gap(AppSpacing.md),
                    _RoomsCard(rooms: report.rooms!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Thứ Hai → Chủ nhật: lấp đầy trung bình (biểu đồ) và ngày đông khách,
/// ngày doanh thu cao nhất — để chỉnh giá theo ngày trong tuần.
class _WeekdaysCard extends StatelessWidget {
  const _WeekdaysCard({required this.weekdays});

  final List<WeekdayStats> weekdays;

  @override
  Widget build(BuildContext context) {
    final counted = weekdays.where((day) => day.days > 0).toList();
    final busiest = counted.reduce((a, b) => b.averageOccupancy > a.averageOccupancy ? b : a);
    final richest = counted.reduce((a, b) => b.averageRevenue > a.averageRevenue ? b : a);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.byWeekday, subtitle: ReportStrings.byWeekdayNote),
          const Gap(AppSpacing.md),
          AppBarChart(
            height: 160,
            axisFormatter: (value) => '${value.round()}%',
            valueFormatter: Fmt.percent,
            points: [
              for (final day in weekdays)
                ChartPoint(
                  ReportStrings.weekdayShort(day.dayOfWeek),
                  day.averageOccupancy,
                  tooltip: ReportStrings.weekdayTooltip(
                    ReportStrings.weekdayName(day.dayOfWeek),
                    Fmt.percent(day.averageOccupancy),
                    Fmt.moneyCompact(day.averageRevenue),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.sm),
          IconText(
            icon: Icons.insights_outlined,
            text: ReportStrings.weekdayHighlights(
              ReportStrings.weekdayName(busiest.dayOfWeek),
              Fmt.percent(busiest.averageOccupancy),
              ReportStrings.weekdayName(richest.dayOfWeek),
              Fmt.moneyCompact(richest.averageRevenue),
            ),
          ),
        ],
      ),
    );
  }
}

/// Từng phòng của cơ sở: lấp đầy và doanh thu, kèm danh sách phòng không có khách.
class _RoomsCard extends StatelessWidget {
  const _RoomsCard({required this.rooms});

  final List<RoomPerformance> rooms;

  @override
  Widget build(BuildContext context) {
    final busy = rooms.where((room) => !room.idle).toList();
    final idle = rooms.where((room) => room.idle).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.byRoom, subtitle: ReportStrings.byRoomNote),
          const Gap(AppSpacing.xs),
          RankedBarList(
            valueFormatter: Fmt.percent,
            items: [
              for (final room in busy)
                RankedBar(
                  label: ReportStrings.roomLabel(room.roomNumber, room.roomTypeName),
                  value: room.occupancyRate,
                  caption: ReportStrings.roomCaption(room.occupiedNights, Fmt.money(room.revenue)),
                ),
            ],
          ),
          if (idle.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            IconText(
              icon: Icons.bedroom_child_outlined,
              text: ReportStrings.idleRooms(idle.map((room) => room.roomNumber).join(', ')),
            ),
          ],
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
                              caption: [
                                ReportStrings.roomTypeCounts(row.rooms, row.bookedRooms, row.roomNights),
                                ReportStrings.roomTypeKpis(
                                  Fmt.percent(row.occupancyRate),
                                  Fmt.moneyCompact(row.adr),
                                  Fmt.moneyCompact(row.revpar),
                                ),
                                if (row.discountRate >= 5)
                                  ReportStrings.belowListPrice(
                                    Fmt.moneyCompact(row.listPrice),
                                    Fmt.percent(row.discountRate),
                                  ),
                              ].join('\n'),
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
                const Gap(AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(
                        title: ReportStrings.byTour,
                        subtitle: ReportStrings.byTourNote,
                      ),
                      const Gap(AppSpacing.xs),
                      RankedBarList(
                        color: AppColors.info,
                        items: [
                          for (final row in report.tours)
                            RankedBar(
                              label: row.name,
                              value: row.revenue,
                              caption: [
                                ReportStrings.tourCaption(row.orders, row.guests),
                                if (row.aiOrders > 0) ReportStrings.aiOrders(row.aiOrders),
                                if (row.packageRoomAmount > 0)
                                  ReportStrings.packageRooms(Fmt.moneyCompact(row.packageRoomAmount)),
                              ].join(' · '),
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
                        if (cancellation.canceled > 0) ...[
                          const Gap(AppSpacing.md),
                          Text(
                            ReportStrings.canceledSplit(
                              cancellation.canceledSelfService,
                              cancellation.canceledFrontDesk,
                              Fmt.money(cancellation.canceledRevenue),
                            ),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                        if (cancellation.tourOrders > 0) ...[
                          const Gap(AppSpacing.xs),
                          Text(
                            ReportStrings.tourCancellations(
                              cancellation.tourOrders,
                              cancellation.tourCanceled,
                              Fmt.percent(cancellation.tourRate),
                              cancellation.tourCanceledByGuest,
                              cancellation.tourCanceledByHotel,
                            ),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                        if (cancellation.canceled > 0 && cancellation.byLeadTime.isNotEmpty) ...[
                          const Gap(AppSpacing.md),
                          Text(ReportStrings.cancelLeadTime, style: AppTextStyles.caption),
                          RankedBarList(
                            color: AppColors.danger,
                            valueFormatter: (value) => AppStrings.bookingsCount(value.round()),
                            items: [
                              for (final bucket in cancellation.byLeadTime)
                                RankedBar(
                                  label: ReportStrings.cancelLeadLabel(bucket.key),
                                  value: bucket.count.toDouble(),
                                  caption: ReportStrings.cancelLeadCaption(
                                    Fmt.percent(bucket.share),
                                    Fmt.money(bucket.revenue),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            ReportStrings.lateCancellations(
                              Fmt.percent(cancellation.lateShare),
                              cancellation.medianLeadDays,
                            ),
                            style: AppTextStyles.bodySmall,
                          ),
                          if (cancellation.canceledByGuest + cancellation.canceledByHotel > 0) ...[
                            const Gap(AppSpacing.xs),
                            Text(
                              ReportStrings.canceledBySide(
                                cancellation.canceledByGuest,
                                cancellation.canceledByHotel,
                              ),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ],
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
                                  [
                                    report.topCustomers[i].phoneNumber,
                                    AppStrings.bookingsCount(report.topCustomers[i].bookings),
                                    if (report.topCustomers[i].tours > 0)
                                      ReportStrings.staffTours(report.topCustomers[i].tours),
                                  ].join(' · '),
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
                                ReportStrings.staffBookings(staff.bookings, staff.completedBookings),
                                if (staff.toursHandled > 0) ReportStrings.staffTours(staff.toursHandled),
                              ].join(' · '),
                              amount: staff.earned,
                            ),
                      ],
                    ),
                  ),
                  if (report.ratings != null) ...[
                    const Gap(AppSpacing.md),
                    _RatingsCard(ratings: report.ratings!, showBranch: cubit.scope is ChainReportScope),
                  ],
                  const Gap(AppSpacing.md),
                  _OriginsCard(origins: report.origins),
                  if (report.assistant != null) ...[
                    const Gap(AppSpacing.md),
                    _AssistantCard(report: report.assistant!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RatingsCard extends StatelessWidget {
  const _RatingsCard({required this.ratings, required this.showBranch});

  final RatingReport ratings;

  /// Báo cáo chuỗi: ghi cơ sở cạnh từng đánh giá.
  final bool showBranch;

  @override
  Widget build(BuildContext context) {
    final average = ratings.averageRating;
    final previous = ratings.previousAverageRating;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: ReportStrings.ratingsTitle,
            subtitle: ReportStrings.ratingsNote(ratings.reviews, Fmt.percent(ratings.reviewRate)),
          ),
          const Gap(AppSpacing.md),
          if (average == null)
            Text(ReportStrings.noReviews, style: AppTextStyles.bodySmall)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${Fmt.decimal(average)} ★', style: AppTextStyles.moneyLarge.colored(AppColors.warning)),
                const Gap(AppSpacing.sm),
                if (previous != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      ReportStrings.previousRating(Fmt.decimal(previous)),
                      style: AppTextStyles.caption,
                    ),
                  ),
              ],
            ),
            const Gap(AppSpacing.xs),
            RankedBarList(
              color: AppColors.warning,
              valueFormatter: (value) => Fmt.number(value),
              items: [
                for (var star = 5; star >= 1; star--)
                  if (ratings.distribution.length >= star)
                    RankedBar(label: ReportStrings.stars(star), value: ratings.distribution[star - 1].toDouble()),
              ],
            ),
            if (ratings.lowReviews.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              Text(ReportStrings.lowReviews, style: AppTextStyles.caption),
              for (final review in ratings.lowReviews)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'★' * review.rating}${'☆' * (5 - review.rating)}  ${review.comments}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        ReportStrings.reviewLine(
                          review.customerName,
                          Fmt.date(review.reviewDate),
                          showBranch ? review.hotelName : '',
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OriginsCard extends StatelessWidget {
  const _OriginsCard({required this.origins});

  static const _shown = 8;

  final List<GuestOrigin> origins;

  @override
  Widget build(BuildContext context) {
    final shown = origins.take(_shown).toList();
    final rest = origins.skip(_shown).toList();
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.originsTitle),
          const Gap(AppSpacing.xs),
          RankedBarList(
            color: AppColors.accent,
            items: [
              for (final origin in shown)
                RankedBar(
                  label: origin.hometown ?? ReportStrings.unknownHometown,
                  value: origin.revenue,
                  caption: ReportStrings.originCaption(
                    origin.guests,
                    origin.bookings,
                    origin.tours,
                    Fmt.percent(origin.share),
                  ),
                ),
            ],
          ),
          if (rest.isNotEmpty)
            Text(
              ReportStrings.otherOrigins(
                rest.length,
                Fmt.money(rest.fold<double>(0, (sum, origin) => sum + origin.revenue)),
              ),
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.report});

  final AiAssistantReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.aiAssistant, subtitle: ReportStrings.aiAssistantNote),
          const Gap(AppSpacing.md),
          if (report.isEmpty)
            Text(ReportStrings.aiEmpty, style: AppTextStyles.bodySmall)
          else ...[
            Row(
              children: [
                PercentRing(percent: report.aiReplyShare, size: 104, caption: ReportStrings.aiReplyRing),
                const Gap(AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniStat(label: ReportStrings.aiConversations, value: Fmt.number(report.conversations)),
                      const Gap(AppSpacing.sm),
                      _MiniStat(
                        label: ReportStrings.aiOnlyConversations,
                        value: Fmt.number(report.aiOnlyConversations),
                      ),
                      const Gap(AppSpacing.sm),
                      _MiniStat(
                        label: ReportStrings.staffConversations,
                        value: Fmt.number(report.staffConversations),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Text(
              ReportStrings.aiReplies(report.guestMessages, report.aiReplies, report.staffReplies),
              style: AppTextStyles.bodySmall,
            ),
            const Gap(AppSpacing.xs),
            Text(
              ReportStrings.replyTimes(report.aiMedianReplySeconds, report.staffMedianReplySeconds),
              style: AppTextStyles.bodySmall,
            ),
            if (report.tourOrders > 0 || report.tourRevenue > 0) ...[
              const Gap(AppSpacing.xs),
              Text(
                ReportStrings.aiTours(
                  report.tourOrders,
                  report.tourOrdersCompleted,
                  report.tourOrdersOpen,
                  report.tourOrdersCanceled,
                ),
                style: AppTextStyles.bodySmall,
              ),
              const Gap(AppSpacing.xs),
              Text(
                ReportStrings.aiTourRevenue(Fmt.money(report.tourRevenue), Fmt.percent(report.tourRevenueShare)),
                style: AppTextStyles.bodySmall,
              ),
            ],
            if (report.waitingForStaff > 0) ...[
              const Gap(AppSpacing.sm),
              Text(
                ReportStrings.waitingForStaff(report.waitingForStaff),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ],
          ],
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
