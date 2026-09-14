import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/report_strings.dart';
import '../utils/formatters.dart';

class ChartPoint {
  const ChartPoint(this.label, this.value, {this.tooltip});

  final String label;
  final double value;

  /// Nhãn đầy đủ khi chạm vào cột/điểm (mặc định dùng [label]).
  final String? tooltip;
}

double _niceCeiling(double value) {
  if (value <= 0) return 1;
  final exponent = (math.log(value) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final normalized = value / magnitude;
  final nice = normalized <= 1
      ? 1
      : normalized <= 2
          ? 2
          : normalized <= 4
              ? 4
              : normalized <= 5
                  ? 5
                  : normalized <= 8
                      ? 8
                      : 10;
  return nice * magnitude;
}

FlTitlesData _titles({
  required List<ChartPoint> points,
  required double top,
  required String Function(double) axisFormatter,
  required int maxLabels,
}) {
  final step = math.max(1, (points.length / maxLabels).ceil());
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 46,
        interval: top / 4,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          space: 6,
          child: Text(axisFormatter(value), style: AppTextStyles.caption),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 26,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (index < 0 || index >= points.length || index % step != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            space: 6,
            child: Text(points[index].label, style: AppTextStyles.caption),
          );
        },
      ),
    ),
  );
}

FlGridData _grid(double top) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: top / 4,
      getDrawingHorizontalLine: (_) =>
          const FlLine(color: AppColors.lineSoft, strokeWidth: 1),
    );

/// Biểu đồ cột (doanh thu theo ngày/tuần/tháng).
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.points,
    this.height = 220,
    this.color = AppColors.primary,
    this.axisFormatter = Fmt.moneyCompact,
    this.valueFormatter = Fmt.money,
    this.highlightLast = false,
    this.maxLabels = 7,
  });

  final List<ChartPoint> points;
  final double height;
  final Color color;
  final String Function(double value) axisFormatter;
  final String Function(double value) valueFormatter;
  final bool highlightLast;
  final int maxLabels;

  @override
  Widget build(BuildContext context) {
    // Toàn số 0 thì trục chia theo mức trần 1 và lặp nhãn — báo không có số liệu.
    if (points.every((point) => point.value <= 0)) return _EmptyChart(height: height);
    final maxValue = points.map((p) => p.value).fold<double>(0, math.max);
    final top = _niceCeiling(maxValue);
    final barWidth = points.length <= 6
        ? 26.0
        : points.length <= 12
            ? 16.0
            : points.length <= 31
                ? 7.0
                : 4.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: top,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: _grid(top),
          titlesData: _titles(
            points: points,
            top: top,
            axisFormatter: axisFormatter,
            maxLabels: maxLabels,
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              tooltipBorderRadius: AppRadius.smAll,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              maxContentWidth: 180,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = points[groupIndex];
                return BarTooltipItem(
                  '${point.tooltip ?? point.label}\n',
                  AppTextStyles.caption.colored(AppColors.line),
                  children: [
                    TextSpan(
                      text: valueFormatter(point.value),
                      style: AppTextStyles.captionStrong.colored(AppColors.surface),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].value,
                    width: barWidth,
                    color: highlightLast && i != points.length - 1
                        ? color.withValues(alpha: 0.45)
                        : color,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(math.min(6, barWidth / 2)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Biểu đồ đường có vùng tô (lấp đầy theo ngày).
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.points,
    this.height = 200,
    this.color = AppColors.primary,
    this.maxY,
    this.axisFormatter = Fmt.moneyCompact,
    this.valueFormatter = Fmt.money,
    this.maxLabels = 6,
  });

  final List<ChartPoint> points;
  final double height;
  final Color color;
  final double? maxY;
  final String Function(double value) axisFormatter;
  final String Function(double value) valueFormatter;
  final int maxLabels;

  @override
  Widget build(BuildContext context) {
    // Toàn số 0 thì trục chia theo mức trần 1 và lặp nhãn — báo không có số liệu.
    if (points.every((point) => point.value <= 0)) return _EmptyChart(height: height);
    final maxValue = points.map((p) => p.value).fold<double>(0, math.max);
    final top = maxY ?? _niceCeiling(maxValue);
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, points.length - 1).toDouble(),
          minY: 0,
          maxY: top,
          borderData: FlBorderData(show: false),
          gridData: _grid(top),
          titlesData: _titles(
            points: points,
            top: top,
            axisFormatter: axisFormatter,
            maxLabels: maxLabels,
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              tooltipBorderRadius: AppRadius.smAll,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.round().clamp(0, points.length - 1)];
                return LineTooltipItem(
                  '${point.tooltip ?? point.label}\n',
                  AppTextStyles.caption.colored(AppColors.line),
                  children: [
                    TextSpan(
                      text: valueFormatter(point.value),
                      style: AppTextStyles.captionStrong.colored(AppColors.surface),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].value),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(show: points.length <= 12),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(ReportStrings.noData, style: AppTextStyles.bodySmall),
      ),
    );
  }
}

class RankedBar {
  const RankedBar({required this.label, required this.value, this.caption});

  final String label;
  final double value;
  final String? caption;
}

/// Danh sách thanh ngang xếp hạng (cơ cấu doanh thu, so sánh cơ sở).
class RankedBarList extends StatelessWidget {
  const RankedBarList({
    super.key,
    required this.items,
    this.valueFormatter = Fmt.money,
    this.color = AppColors.primary,
  });

  final List<RankedBar> items;
  final String Function(double value) valueFormatter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: Text(ReportStrings.noData, style: AppTextStyles.bodySmall)),
      );
    }
    final maxValue = items.map((e) => e.value).fold<double>(0, math.max);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      valueFormatter(item.value),
                      style: AppTextStyles.tabular.weight(FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: maxValue <= 0 ? 0 : item.value / maxValue,
                    color: color,
                    backgroundColor: AppColors.surfaceSunk,
                  ),
                ),
                if (item.caption != null) ...[
                  const SizedBox(height: 4),
                  Text(item.caption!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Vòng phần trăm (tỷ lệ lấp đầy, tỷ lệ huỷ).
class PercentRing extends StatelessWidget {
  const PercentRing({
    super.key,
    required this.percent,
    this.size = 120,
    this.color = AppColors.primary,
    this.caption,
  });

  final double percent;
  final double size;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final value = (percent / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: size * 0.09,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: AppColors.surfaceSunk,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Fmt.percent(percent), style: AppTextStyles.metric.copyWith(fontSize: size * 0.2)),
                if (caption != null)
                  Text(caption!, style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
