import 'package:booking_app_mobile/features/report/domain/entities/report_entities.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_range.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_views.dart';
import 'package:booking_app_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:booking_app_mobile/features/report/domain/usecases/report_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ghi lại khoảng ngày và độ chi tiết mà use case hỏi BE; [byYear] là các mốc trả về theo năm.
class _RecordingReports implements ReportRepository {
  _RecordingReports([this.byYear = const {}]);

  final Map<int, List<RevenueBucket>> byYear;
  final calls = <ReportRange>[];
  ReportRange? get asked => calls.isEmpty ? null : calls.first;
  RevenueGranularity? askedGranularity;

  @override
  Future<List<RevenueBucket>> trend(ReportScope scope, ReportRange range, RevenueGranularity granularity) async {
    calls.add(range);
    askedGranularity = granularity;
    return byYear[range.from.year] ?? const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  final today = DateTime(2026, 11, 3);
  final october = ReportRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31));

  Future<ReportRange?> ask(RevenueGranularity granularity, ReportRange range) async {
    final reports = _RecordingReports();
    await LoadRevenueReport(reports)(const BranchReportScope(6), range, granularity, today: today);
    expect(reports.askedGranularity, granularity);
    return reports.asked;
  }

  test('theo ngày và tuần: đúng khoảng đang xem', () async {
    expect(await ask(RevenueGranularity.day, october), october);
    expect(await ask(RevenueGranularity.week, october), october);
  });

  test('theo tháng: các tháng của năm đó đến hôm nay; năm cũ thì cả năm', () async {
    expect(await ask(RevenueGranularity.month, october), ReportRange(DateTime(2026), today));
    final lastYear = ReportRange(DateTime(2025, 3, 1), DateTime(2025, 3, 31));
    expect(await ask(RevenueGranularity.month, lastYear), ReportRange(DateTime(2025), DateTime(2025, 12, 31)));
  });

  test('theo năm: 5 năm gần nhất', () async {
    expect(await ask(RevenueGranularity.year, october), ReportRange(DateTime(2022), today));
  });

  test('theo tháng: mỗi tháng kèm cùng kỳ năm trước, tháng đang chạy so đúng chừng ấy ngày', () async {
    RevenueBucket month(int year, int m, double revenue) =>
        RevenueBucket(start: DateTime(year, m), end: DateTime(year, m, 28), revenue: revenue, bookings: 1);
    final reports = _RecordingReports({
      2026: [month(2026, 10, 12000000), month(2026, 11, 1000000)],
      2025: [month(2025, 10, 8000000)],
    });

    final report = await LoadRevenueReport(reports)(
      const BranchReportScope(6),
      october,
      RevenueGranularity.month,
      today: today,
    );

    expect(reports.calls.last, ReportRange(DateTime(2025), DateTime(2025, 11, 3)));
    expect(report.buckets.first.previousRevenue, 8000000);
    expect(report.buckets.first.yearOverYear, 50);
    // tháng 11/2025 không có doanh thu: không có mốc, không tính %
    expect(report.buckets.last.previousRevenue, isNull);
    expect(report.buckets.last.yearOverYear, isNull);
  });
}
