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

  /// Đơn tour hoàn tất theo ngày đi, gộp theo tour.
  Future<List<TourRevenue>> revenueByTour(ReportScope scope, ReportRange range);

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

  /// Từng cơ sở của chuỗi trong khoảng đã chọn, nhiều doanh thu nhất trước.
  Future<List<BranchPerformance>> branchPerformance(
    ChainReportScope scope,
    ReportRange range,
  );

  /// Thứ Hai → Chủ nhật: lấp đầy và doanh thu trung bình mỗi ngày.
  Future<List<WeekdayStats>> weekdays(ReportScope scope, ReportRange range);

  /// Từng phòng của cơ sở trong khoảng đã chọn (chỉ cấp cơ sở).
  Future<List<RoomPerformance>> roomPerformance(BranchReportScope scope, ReportRange range);

  /// Doanh thu dự kiến [days] ngày tới (tính cả hôm nay) và tiền còn phải thu.
  Future<RevenueOutlook> outlook(ReportScope scope, {int days});

  /// KPI của khoảng đã chọn cạnh kỳ trước (BE chọn theo lịch, xem [RevenueSummary]).
  Future<RevenueSummary> summary(ReportScope scope, ReportRange range);

  Future<List<int>> export(ReportScope scope, ReportRange range);
}
