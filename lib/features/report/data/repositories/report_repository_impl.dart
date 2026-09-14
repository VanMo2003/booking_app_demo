import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_range.dart';
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

  @override
  Future<List<RevenueByMonth>> revenueLast5Months(ReportScope scope) async =>
      (await _remote.get(scope, 'monthly/last-5-months'))
          .parseList(ReportModel.byMonth);

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
  Future<List<int>> export(ReportScope scope, ReportRange range) =>
      _remote.export(scope, _inclusive(range));
}
