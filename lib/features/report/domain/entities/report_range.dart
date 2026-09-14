import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_utils.dart';

enum ReportPreset { last7Days, thisMonth, lastMonth, thisYear, custom }

enum RevenueGranularity { day, week, month, year }

/// Khoảng báo cáo người dùng chọn — tính cả hai đầu. BE bắt buộc
/// `from` trước `to`, nên khoảng một ngày được nới thành hai ngày.
class ReportRange extends Equatable {
  factory ReportRange(DateTime from, DateTime to) {
    final start = DateOnly.of(from);
    var end = DateOnly.of(to);
    if (!end.isAfter(start)) end = DateOnly.addDays(start, 1);
    return ReportRange._(start, end);
  }

  const ReportRange._(this.from, this.to);

  factory ReportRange.preset(ReportPreset preset, {DateTime? today}) {
    final now = DateOnly.of(today ?? DateTime.now());
    return switch (preset) {
      ReportPreset.last7Days => ReportRange(DateOnly.addDays(now, -6), now),
      ReportPreset.thisMonth => ReportRange(DateOnly.startOfMonth(now), now),
      ReportPreset.lastMonth => ReportRange(
          DateTime(now.year, now.month - 1),
          DateTime(now.year, now.month, 0),
        ),
      ReportPreset.thisYear => ReportRange(DateTime(now.year), now),
      ReportPreset.custom => ReportRange(DateOnly.addDays(now, -29), now),
    };
  }

  final DateTime from;
  final DateTime to;

  /// Số ngày trong khoảng (tính cả hai đầu).
  int get days => DateOnly.nights(from, to) + 1;

  /// Mốc kết thúc loại trừ cho API lấp đầy (`[from, to)`).
  DateTime get exclusiveEnd => DateOnly.addDays(to, 1);

  @override
  List<Object?> get props => [from, to];
}
