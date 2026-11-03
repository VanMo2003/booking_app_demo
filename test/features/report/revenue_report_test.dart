import 'package:booking_app_mobile/features/report/domain/entities/report_entities.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_range.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_views.dart';
import 'package:booking_app_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:booking_app_mobile/features/report/domain/usecases/report_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ghi lại khoảng ngày và độ chi tiết mà use case hỏi BE.
class _RecordingReports implements ReportRepository {
  ReportRange? asked;
  RevenueGranularity? askedGranularity;

  @override
  Future<List<RevenueBucket>> trend(ReportScope scope, ReportRange range, RevenueGranularity granularity) async {
    asked = range;
    askedGranularity = granularity;
    return const [];
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
}
