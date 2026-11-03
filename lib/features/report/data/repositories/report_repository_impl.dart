import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/report_views.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';
import '../models/report_models.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remote);

  final ReportRemoteDataSource _remote;

  /// Các báo cáo doanh thu, cơ cấu, khách, nhân viên, tỷ lệ huỷ: `to` tính cả ngày cuối.
  Map<String, dynamic> _inclusive(ReportRange range) => {
        'from': Fmt.apiDate(range.from),
        'to': Fmt.apiDate(range.to),
      };

  /// Lấp đầy: BE tính `[from, to)`, nên gửi ngày sau ngày cuối.
  Map<String, dynamic> _exclusive(ReportRange range) => {
        'from': Fmt.apiDate(range.from),
        'to': Fmt.apiDate(range.exclusiveEnd),
      };

  @override
  Future<List<RevenueByDate>> revenueByDay(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'daily', _inclusive(range)))
          .parseList(ReportModel.byDate);

  @override
  Future<List<RevenueByWeek>> revenueByWeek(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'weekly', _inclusive(range)))
          .parseList(ReportModel.byWeek);

  @override
  Future<List<RevenueByMonth>> revenueByMonth(ReportScope scope, int year) async =>
      (await _remote.get(scope, 'monthly', {'year': year}))
          .parseList(ReportModel.byMonth);

  /// Lấy từ `trend` (đơn phòng + tour) thay vì `monthly/last-5-months` (chỉ đơn phòng), để cột tháng này
  /// khớp thẻ "Doanh thu tháng này" vốn đã tính tour.
  @override
  Future<List<RevenueByMonth>> revenueLast5Months(ReportScope scope) async {
    final today = DateOnly.today();
    final months = await trend(
      scope,
      ReportRange(DateTime(today.year, today.month - 4), today),
      RevenueGranularity.month,
    );
    return [
      for (final month in months)
        RevenueByMonth(
          year: month.start.year,
          month: month.start.month,
          revenue: month.revenue,
          bookings: month.bookings,
        ),
    ];
  }

  @override
  Future<List<RevenueByYear>> revenueByYear(ReportScope scope) async =>
      (await _remote.get(scope, 'yearly')).parseList(ReportModel.byYear);

  @override
  Future<OccupancySummary> occupancy(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'occupancy', _exclusive(range)))
          .parse(ReportModel.occupancy);

  @override
  Future<List<DailyOccupancy>> occupancyDaily(
    BranchReportScope scope,
    ReportRange range,
  ) async =>
      (await _remote.get(scope, 'occupancy/daily', _exclusive(range)))
          .parseList(ReportModel.dailyOccupancy);

  @override
  Future<List<RoomTypeRevenue>> revenueByRoomType(
    ReportScope scope,
    ReportRange range,
  ) async =>
      (await _remote.get(scope, 'revenue-by-room-type', _inclusive(range)))
          .parseList(ReportModel.roomType);

  @override
  Future<List<ServiceRevenue>> revenueByService(
    ReportScope scope,
    ReportRange range,
  ) async =>
      (await _remote.get(scope, 'revenue-by-service', _inclusive(range)))
          .parseList(ReportModel.service);

  @override
  Future<List<TourRevenue>> revenueByTour(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'revenue-by-tour', _inclusive(range))).parseList(ReportModel.tour);

  @override
  Future<List<TopCustomer>> topCustomers(
    ReportScope scope,
    ReportRange range, {
    int limit = AppConstants.topCustomersLimit,
  }) async =>
      (await _remote.get(
        scope,
        'top-customers',
        {..._inclusive(range), 'limit': limit},
      ))
          .parseList(ReportModel.topCustomer);

  @override
  Future<List<StaffPerformance>> staffPerformance(
    ReportScope scope,
    ReportRange range,
  ) async =>
      (await _remote.get(scope, 'staff-performance', _inclusive(range)))
          .parseList(ReportModel.staff);

  @override
  Future<CancellationStats> cancellation(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'cancellation-rate', _inclusive(range)))
          .parse(ReportModel.cancellation);

  @override
  Future<BookingHours> bookingHours(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'booking-hours', _inclusive(range))).parse(ReportModel.bookingHours);

  @override
  Future<Collections> collections(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'collections', _inclusive(range))).parse(ReportModel.collections);

  @override
  Future<List<GuestOrigin>> guestOrigins(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'guest-origins', _inclusive(range))).parseList(ReportModel.guestOrigin);

  @override
  Future<RatingReport> ratings(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'ratings', _inclusive(range))).parse(ReportModel.ratings);

  @override
  Future<AiAssistantReport> aiAssistant(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'ai-assistant', _inclusive(range))).parse(ReportModel.aiAssistant);

  @override
  Future<List<BranchPerformance>> branchPerformance(
    ChainReportScope scope,
    ReportRange range,
  ) async =>
      (await _remote.get(scope, 'branches', _inclusive(range))).parseList(ReportModel.branch);

  @override
  Future<List<Receivable>> receivables(ReportScope scope) async =>
      (await _remote.get(scope, 'receivables')).parseList(ReportModel.receivable);

  @override
  Future<TargetProgress> targetProgress(int hotelId, String month) async =>
      (await _remote.get(BranchReportScope(hotelId), 'targets/progress', {'month': month}))
          .parse(ReportModel.target);

  @override
  Future<ChainTargetProgress> chainTargetProgress(int hotelChainId, String month) async =>
      (await _remote.get(ChainReportScope(hotelChainId), 'targets/progress', {'month': month}))
          .parse(ReportModel.chainTarget);

  @override
  Future<TargetProgress> setTarget({
    required int hotelId,
    required String month,
    required double amount,
  }) async =>
      (await _remote.put('targets', {'hotelId': hotelId, 'month': month, 'amount': amount}))
          .parse(ReportModel.target);

  @override
  Future<List<RevenueBucket>> trend(
    ReportScope scope,
    ReportRange range,
    RevenueGranularity granularity,
  ) async =>
      (await _remote.get(scope, 'trend', {..._inclusive(range), 'granularity': granularity.name}))
          .parseList(ReportModel.trendBucket);

  @override
  Future<List<WeekdayStats>> weekdays(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'weekdays', _inclusive(range))).parseList(ReportModel.weekday);

  @override
  Future<List<RoomPerformance>> roomPerformance(BranchReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'rooms', _inclusive(range))).parseList(ReportModel.room);

  @override
  Future<RevenueOutlook> outlook(
    ReportScope scope, {
    int days = AppConstants.outlookDays,
  }) async =>
      (await _remote.get(scope, 'outlook', {'days': days})).parse(ReportModel.outlook);

  @override
  Future<List<BranchOutlook>> branchOutlook(
    ChainReportScope scope, {
    int days = AppConstants.outlookDays,
  }) async =>
      (await _remote.get(scope, 'outlook/branches', {'days': days})).parseList(ReportModel.branchOutlook);

  @override
  Future<RevenueSummary> summary(ReportScope scope, ReportRange range) async =>
      (await _remote.get(scope, 'summary', _inclusive(range))).parse(ReportModel.summary);

  @override
  Future<List<int>> export(ReportScope scope, ReportRange range) =>
      _remote.export(scope, _inclusive(range));
}
