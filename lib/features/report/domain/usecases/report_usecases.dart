import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../entities/report_entities.dart';
import '../entities/report_range.dart';
import '../entities/report_views.dart';
import '../repositories/report_repository.dart';

/// Doanh thu theo độ chi tiết; điền 0 cho các mốc không có đơn để biểu đồ liền mạch.
@injectable
class LoadRevenueReport {
  const LoadRevenueReport(this._repository);

  final ReportRepository _repository;

  Future<RevenueReport> call(
    ReportScope scope,
    ReportRange range,
    RevenueGranularity granularity,
  ) async {
    final buckets = switch (granularity) {
      RevenueGranularity.day => await _daily(scope, range),
      RevenueGranularity.week => await _weekly(scope, range),
      RevenueGranularity.month => await _monthly(scope, range),
      RevenueGranularity.year => await _yearly(scope),
    };
    return RevenueReport(granularity: granularity, buckets: buckets);
  }

  Future<List<RevenueBucket>> _daily(ReportScope scope, ReportRange range) async {
    final rows = await _repository.revenueByDay(scope, range);
    final byDate = {for (final row in rows) Fmt.apiDate(row.date): row};
    return DateOnly.daysInRange(range.from, range.to).map((day) {
      final row = byDate[Fmt.apiDate(day)];
      return RevenueBucket(
        start: day,
        end: day,
        revenue: row?.revenue ?? 0,
        bookings: row?.bookings ?? 0,
      );
    }).toList();
  }

  Future<List<RevenueBucket>> _weekly(ReportScope scope, ReportRange range) async {
    final rows = await _repository.revenueByWeek(scope, range);
    return rows
        .map(
          (row) => RevenueBucket(
            start: row.startDate ?? range.from,
            end: row.endDate ?? range.to,
            revenue: row.revenue,
            bookings: row.bookings,
            week: row.week,
          ),
        )
        .toList();
  }

  Future<List<RevenueBucket>> _monthly(ReportScope scope, ReportRange range) async {
    final year = range.to.year;
    final rows = await _repository.revenueByMonth(scope, year);
    final lastMonth = year == DateTime.now().year ? DateTime.now().month : 12;
    return List.generate(lastMonth, (index) {
      final month = index + 1;
      final row = rows.firstWhereOrNull((r) => r.month == month);
      return RevenueBucket(
        start: DateTime(year, month),
        end: DateOnly.endOfMonth(DateTime(year, month)),
        revenue: row?.revenue ?? 0,
        bookings: row?.bookings ?? 0,
      );
    });
  }

  Future<List<RevenueBucket>> _yearly(ReportScope scope) async {
    final rows = await _repository.revenueByYear(scope);
    return (rows..sort((a, b) => a.year.compareTo(b.year)))
        .map(
          (row) => RevenueBucket(
            start: DateTime(row.year),
            end: DateTime(row.year, 12, 31),
            revenue: row.revenue,
            bookings: row.bookings,
          ),
        )
        .toList();
  }
}

@injectable
class LoadOccupancyReport {
  const LoadOccupancyReport(this._repository);

  final ReportRepository _repository;

  Future<OccupancyReport> call(ReportScope scope, ReportRange range) async {
    final summaryFuture = _repository.occupancy(scope, range);
    final canLoadDaily = scope is BranchReportScope &&
        range.days <= AppConstants.maxDailyReportDays;
    final daily = canLoadDaily
        ? await _repository.occupancyDaily(scope, range)
        : null;
    return OccupancyReport(summary: await summaryFuture, daily: daily);
  }
}

@injectable
class LoadBreakdownReport {
  const LoadBreakdownReport(this._repository);

  final ReportRepository _repository;

  Future<BreakdownReport> call(ReportScope scope, ReportRange range) async {
    final roomTypes = _repository.revenueByRoomType(scope, range);
    final services = _repository.revenueByService(scope, range);
    return BreakdownReport(
      roomTypes: (await roomTypes)..sort((a, b) => b.revenue.compareTo(a.revenue)),
      services: (await services)..sort((a, b) => b.revenue.compareTo(a.revenue)),
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
    return PeopleReport(
      topCustomers: await customers,
      staff: (await staff)..sort((a, b) => b.revenue.compareTo(a.revenue)),
      cancellation: await cancellation,
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

/// So sánh doanh thu cả năm giữa các cơ sở trong chuỗi.
@injectable
class LoadBranchComparison {
  const LoadBranchComparison(this._repository);

  final ReportRepository _repository;

  Future<List<BranchRevenue>> call(List<Hotel> hotels, int year) async {
    final results = await Future.wait(
      hotels.map((hotel) async {
        final months =
            await _repository.revenueByMonth(BranchReportScope(hotel.id), year);
        return BranchRevenue(
          hotel: hotel,
          revenue: months.fold(0, (sum, m) => sum + m.revenue),
          bookings: months.fold(0, (sum, m) => sum + m.bookings),
        );
      }),
    );
    return results..sort((a, b) => b.revenue.compareTo(a.revenue));
  }
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
    return BranchDashboard(
      last5Months: [...await last5]..sort((a, b) => a.monthIndex.compareTo(b.monthIndex)),
      bookings: await bookings,
      occupancy: await occupancy,
      cancellation: await cancellation,
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
