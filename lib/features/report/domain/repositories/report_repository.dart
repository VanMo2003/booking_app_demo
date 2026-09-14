import '../entities/report_entities.dart';
import '../entities/report_range.dart';

abstract interface class ReportRepository {
  Future<List<RevenueByDate>> revenueByDay(ReportScope scope, ReportRange range);

  Future<List<RevenueByWeek>> revenueByWeek(ReportScope scope, ReportRange range);

  Future<List<RevenueByMonth>> revenueByMonth(ReportScope scope, int year);

  /// 5 tháng gần nhất, tháng trống vẫn có mặt với giá trị 0.
  Future<List<RevenueByMonth>> revenueLast5Months(ReportScope scope);

  Future<List<RevenueByYear>> revenueByYear(ReportScope scope);

  Future<OccupancySummary> occupancy(ReportScope scope, ReportRange range);

  /// Chỉ có ở cấp cơ sở, tối đa 92 ngày.
  Future<List<DailyOccupancy>> occupancyDaily(
    BranchReportScope scope,
    ReportRange range,
  );

  Future<List<RoomTypeRevenue>> revenueByRoomType(
    ReportScope scope,
    ReportRange range,
  );

  Future<List<ServiceRevenue>> revenueByService(
    ReportScope scope,
    ReportRange range,
  );

  Future<List<TopCustomer>> topCustomers(
    ReportScope scope,
    ReportRange range, {
    int limit,
  });

  Future<List<StaffPerformance>> staffPerformance(
    ReportScope scope,
    ReportRange range,
  );

  Future<CancellationStats> cancellation(ReportScope scope, ReportRange range);

  Future<List<int>> export(ReportScope scope, ReportRange range);
}
