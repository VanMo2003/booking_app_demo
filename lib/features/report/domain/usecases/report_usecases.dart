import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../entities/report_entities.dart';
import '../entities/report_range.dart';
import '../entities/report_views.dart';
import '../repositories/report_repository.dart';

/// Diễn biến doanh thu (đơn phòng + tour) theo độ chi tiết; BE trả đủ các mốc,
/// mốc trống có giá trị 0. Theo ngày/tuần là đúng khoảng đang xem; theo tháng
/// là các tháng của năm chứa ngày cuối khoảng (đến hôm nay); theo năm là 5 năm
/// gần nhất.
@injectable
class LoadRevenueReport {
  const LoadRevenueReport(this._repository);

  final ReportRepository _repository;

  /// Số năm của chế độ xem theo năm.
  static const years = 5;

  Future<RevenueReport> call(
    ReportScope scope,
    ReportRange range,
    RevenueGranularity granularity, {
    DateTime? today,
  }) async {
    final now = DateOnly.of(today ?? DateTime.now());
    final window = switch (granularity) {
      RevenueGranularity.day || RevenueGranularity.week => range,
      RevenueGranularity.month => ReportRange(
          DateTime(range.to.year),
          range.to.year == now.year ? now : DateTime(range.to.year, 12, 31),
        ),
      RevenueGranularity.year => ReportRange(DateTime(now.year - years + 1), now),
    };
    final buckets = await _repository.trend(scope, window, granularity);
    if (granularity != RevenueGranularity.month) {
      return RevenueReport(granularity: granularity, buckets: buckets);
    }
    // cùng kỳ năm trước: đúng chừng ấy ngày, nên tháng đang chạy dở so với đúng phần đó của năm trước
    final lastYear = await _repository.trend(scope, _yearBefore(window), granularity);
    final byMonth = {for (final bucket in lastYear) bucket.start.month: bucket.revenue};
    return RevenueReport(
      granularity: granularity,
      buckets: [for (final bucket in buckets) bucket.withPrevious(byMonth[bucket.start.month])],
    );
  }

  /// [range] lùi một năm; 29/02 thành 28/02.
  static ReportRange _yearBefore(ReportRange range) {
    DateTime back(DateTime day) {
      final lastDay = DateOnly.endOfMonth(DateTime(day.year - 1, day.month)).day;
      return DateTime(day.year - 1, day.month, day.day > lastDay ? lastDay : day.day);
    }

    return ReportRange(back(range.from), back(range.to));
  }
}

/// Tổng quan kỳ: tổng doanh thu gồm cả tour, ADR/RevPAR và so sánh kỳ trước.
@injectable
class LoadRevenueSummary {
  const LoadRevenueSummary(this._repository);

  final ReportRepository _repository;

  Future<RevenueSummary> call(ReportScope scope, ReportRange range) =>
      _repository.summary(scope, range);
}

/// Đặt (hoặc bỏ, khi [amount] = 0) mục tiêu doanh thu tháng của một cơ sở.
@injectable
class SetRevenueTarget {
  const SetRevenueTarget(this._repository);

  final ReportRepository _repository;

  Future<TargetProgress> call({required int hotelId, required String month, required double amount}) =>
      _repository.setTarget(hotelId: hotelId, month: month, amount: amount);
}

/// "2026-10" cho tháng chứa [date] — khoá tháng của mục tiêu doanh thu.
String monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

@injectable
class LoadOccupancyReport {
  const LoadOccupancyReport(this._repository);

  final ReportRepository _repository;

  Future<OccupancyReport> call(ReportScope scope, ReportRange range) async {
    final summaryFuture = _repository.occupancy(scope, range);
    final canLoadDaily = scope is BranchReportScope &&
        range.days <= AppConstants.maxDailyReportDays;
    final roomsFuture =
        scope is BranchReportScope ? _repository.roomPerformance(scope, range) : null;
    final weekdaysFuture = _repository.weekdays(scope, range);
    final daily = canLoadDaily
        ? await _repository.occupancyDaily(scope, range)
        : null;
    return OccupancyReport(
      summary: await summaryFuture,
      daily: daily,
      rooms: await roomsFuture,
      weekdays: await weekdaysFuture,
    );
  }
}

@injectable
class LoadBreakdownReport {
  const LoadBreakdownReport(this._repository);

  final ReportRepository _repository;

  Future<BreakdownReport> call(ReportScope scope, ReportRange range) async {
    final roomTypes = _repository.revenueByRoomType(scope, range);
    final services = _repository.revenueByService(scope, range);
    final tours = _repository.revenueByTour(scope, range);
    final collections =
        range.days <= AppConstants.maxDailyReportDays ? _repository.collections(scope, range) : null;
    return BreakdownReport(
      roomTypes: (await roomTypes)..sort((a, b) => b.revenue.compareTo(a.revenue)),
      services: (await services)..sort((a, b) => b.revenue.compareTo(a.revenue)),
      tours: await tours,
      collections: await collections,
    );
  }
}

@injectable
class LoadPeopleReport {
  const LoadPeopleReport(this._repository);

  final ReportRepository _repository;

  Future<PeopleReport> call(ReportScope scope, ReportRange range) async {
    final customers = _repository.topCustomers(scope, range);
    final staff = _repository.staffPerformance(scope, range);
    final cancellation = _repository.cancellation(scope, range);
    final assistant = _repository.aiAssistant(scope, range);
    final origins = _repository.guestOrigins(scope, range);
    final ratings = _repository.ratings(scope, range);
    final hours = _repository.bookingHours(scope, range);
    return PeopleReport(
      topCustomers: await customers,
      staff: (await staff)..sort((a, b) => b.earned.compareTo(a.earned)),
      cancellation: await cancellation,
      assistant: await assistant,
      origins: await origins,
      ratings: await ratings,
      hours: await hours,
    );
  }
}

/// File Excel đặt tên theo đúng mẫu của BE (header Content-Disposition không
/// đọc được qua CORS).
@injectable
class ExportReport {
  const ExportReport(this._repository);

  final ReportRepository _repository;

  Future<ReportFile> call(ReportScope scope, ReportRange range) async => ReportFile(
        fileName:
            '${scope.exportFilePrefix}_${Fmt.apiDate(range.from)}_${Fmt.apiDate(range.to)}.xlsx',
        bytes: await _repository.export(scope, range),
      );
}

/// Các cơ sở của chuỗi trong khoảng đang xem: doanh thu, tỷ trọng, KPI và
/// tăng trưởng so với kỳ trước của từng cơ sở.
@injectable
class LoadBranchComparison {
  const LoadBranchComparison(this._repository);

  final ReportRepository _repository;

  Future<List<BranchPerformance>> call(ChainReportScope scope, ReportRange range) =>
      _repository.branchPerformance(scope, range);
}

@injectable
class LoadBranchDashboard {
  const LoadBranchDashboard(this._reports, this._bookings);

  final ReportRepository _reports;
  final BookingRepository _bookings;

  Future<BranchDashboard> call(int hotelId) async {
    final scope = BranchReportScope(hotelId);
    final month = ReportRange.preset(ReportPreset.thisMonth);
    final last5 = _reports.revenueLast5Months(scope);
    final bookings = _bookings.byHotel(hotelId);
    final occupancy = _optional(_reports.occupancy(scope, month));
    final cancellation = _optional(_reports.cancellation(scope, month));
    final outlook = _optional(_reports.outlook(scope));
    final monthSummary = _optional(_reports.summary(scope, month));
    final target = _optional(_reports.targetProgress(hotelId, monthKey(DateTime.now())));
    final today = DateOnly.today();
    final collections = _optional(_reports.collections(scope, ReportRange(today, today)));
    return BranchDashboard(
      last5Months: [...await last5]..sort((a, b) => a.monthIndex.compareTo(b.monthIndex)),
      bookings: await bookings,
      occupancy: await occupancy,
      cancellation: await cancellation,
      outlook: await outlook,
      monthSummary: await monthSummary,
      target: await target,
      todayCollections: await collections,
    );
  }

  Future<T?> _optional<T>(Future<T> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }
}
