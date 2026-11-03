import 'package:equatable/equatable.dart';

import '../../../booking/domain/entities/booking.dart';
import 'report_entities.dart';
import 'report_range.dart';

/// Một cột doanh thu (ngày / tuần / tháng / năm) sau khi đã điền đủ các mốc trống.
class RevenueBucket extends Equatable {
  const RevenueBucket({
    required this.start,
    required this.end,
    required this.revenue,
    required this.bookings,
    this.week,
    this.tourRevenue = 0,
    this.tours = 0,
    this.previousRevenue,
  });

  final DateTime start;
  final DateTime end;

  /// Tổng: đơn phòng (gồm dịch vụ) + tour.
  final double revenue;
  final int bookings;

  /// Số tuần ISO khi xem theo tuần.
  final int? week;

  /// Phần tour trong [revenue] và số đơn tour hoàn tất.
  final double tourRevenue;
  final int tours;

  /// Cùng kỳ năm trước (chỉ khi xem theo tháng); `null` khi không so.
  final double? previousRevenue;

  /// % thay đổi so với cùng kỳ năm trước; `null` khi năm trước bằng 0 hoặc không so.
  double? get yearOverYear {
    final before = previousRevenue;
    if (before == null || before <= 0) return null;
    return (revenue - before) / before * 100;
  }

  RevenueBucket withPrevious(double? previous) => RevenueBucket(
        start: start,
        end: end,
        revenue: revenue,
        bookings: bookings,
        week: week,
        tourRevenue: tourRevenue,
        tours: tours,
        previousRevenue: previous,
      );

  @override
  List<Object?> get props => [start, end, revenue, bookings, week, tourRevenue, tours, previousRevenue];
}

class RevenueReport extends Equatable {
  const RevenueReport({required this.granularity, required this.buckets});

  final RevenueGranularity granularity;
  final List<RevenueBucket> buckets;

  double get totalRevenue => buckets.fold(0, (sum, b) => sum + b.revenue);
  int get totalBookings => buckets.fold(0, (sum, b) => sum + b.bookings);
  double get averagePerBooking =>
      totalBookings == 0 ? 0 : totalRevenue / totalBookings;

  @override
  List<Object?> get props => [granularity, buckets];
}

class OccupancyReport extends Equatable {
  const OccupancyReport({
    required this.summary,
    this.daily,
    this.rooms,
    this.weekdays = const [],
  });

  final OccupancySummary summary;

  /// `null` khi xem cả chuỗi hoặc khoảng quá 92 ngày.
  final List<DailyOccupancy>? daily;

  /// Từng phòng của cơ sở, đông khách nhất trước; `null` khi xem cả chuỗi.
  final List<RoomPerformance>? rooms;

  /// Thứ Hai → Chủ nhật.
  final List<WeekdayStats> weekdays;

  @override
  List<Object?> get props => [summary, daily, rooms, weekdays];
}

class BreakdownReport extends Equatable {
  const BreakdownReport({
    required this.roomTypes,
    required this.services,
    required this.tours,
  });

  final List<RoomTypeRevenue> roomTypes;
  final List<ServiceRevenue> services;
  final List<TourRevenue> tours;

  @override
  List<Object?> get props => [roomTypes, services, tours];
}

class PeopleReport extends Equatable {
  const PeopleReport({
    required this.topCustomers,
    required this.staff,
    required this.cancellation,
    this.assistant,
  });

  final List<TopCustomer> topCustomers;
  final List<StaffPerformance> staff;
  final CancellationStats cancellation;
  final AiAssistantReport? assistant;

  @override
  List<Object?> get props => [topCustomers, staff, cancellation, assistant];
}

class ReportFile {
  const ReportFile({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

/// Số liệu cho màn Tổng quan của một cơ sở.
class BranchDashboard extends Equatable {
  const BranchDashboard({
    required this.last5Months,
    required this.bookings,
    this.occupancy,
    this.cancellation,
    this.outlook,
    this.monthSummary,
    this.target,
  });

  final List<RevenueByMonth> last5Months;
  final List<Booking> bookings;
  final OccupancySummary? occupancy;
  final CancellationStats? cancellation;

  /// Doanh thu dự kiến 30 ngày tới; `null` khi không tải được.
  final RevenueOutlook? outlook;

  /// Tổng quan từ đầu tháng đến hôm nay (gồm tour) cạnh cùng các ngày của tháng trước.
  final RevenueSummary? monthSummary;

  /// Tháng này so với mục tiêu; `null` khi không tải được.
  final TargetProgress? target;

  RevenueByMonth? get currentMonth =>
      last5Months.isEmpty ? null : last5Months.last;

  RevenueByMonth? get previousMonth =>
      last5Months.length < 2 ? null : last5Months[last5Months.length - 2];

  @override
  List<Object?> get props =>
      [last5Months, bookings, occupancy, cancellation, outlook, monthSummary, target];
}
