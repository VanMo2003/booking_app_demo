import 'package:equatable/equatable.dart';

import '../../../booking/domain/entities/booking.dart';
import '../../../hotel/domain/entities/hotel.dart';
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
  });

  final DateTime start;
  final DateTime end;
  final double revenue;
  final int bookings;

  /// Số tuần ISO khi xem theo tuần.
  final int? week;

  @override
  List<Object?> get props => [start, end, revenue, bookings, week];
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
  const OccupancyReport({required this.summary, this.daily});

  final OccupancySummary summary;

  /// `null` khi xem cả chuỗi hoặc khoảng quá 92 ngày.
  final List<DailyOccupancy>? daily;

  @override
  List<Object?> get props => [summary, daily];
}

class BreakdownReport extends Equatable {
  const BreakdownReport({required this.roomTypes, required this.services});

  final List<RoomTypeRevenue> roomTypes;
  final List<ServiceRevenue> services;

  @override
  List<Object?> get props => [roomTypes, services];
}

class PeopleReport extends Equatable {
  const PeopleReport({
    required this.topCustomers,
    required this.staff,
    required this.cancellation,
  });

  final List<TopCustomer> topCustomers;
  final List<StaffPerformance> staff;
  final CancellationStats cancellation;

  @override
  List<Object?> get props => [topCustomers, staff, cancellation];
}

class ReportFile {
  const ReportFile({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

class BranchRevenue extends Equatable {
  const BranchRevenue({required this.hotel, required this.revenue, required this.bookings});

  final Hotel hotel;
  final double revenue;
  final int bookings;

  @override
  List<Object?> get props => [hotel, revenue, bookings];
}

/// Số liệu cho màn Tổng quan của một cơ sở.
class BranchDashboard extends Equatable {
  const BranchDashboard({
    required this.last5Months,
    required this.bookings,
    this.occupancy,
    this.cancellation,
  });

  final List<RevenueByMonth> last5Months;
  final List<Booking> bookings;
  final OccupancySummary? occupancy;
  final CancellationStats? cancellation;

  RevenueByMonth? get currentMonth =>
      last5Months.isEmpty ? null : last5Months.last;

  RevenueByMonth? get previousMonth =>
      last5Months.length < 2 ? null : last5Months[last5Months.length - 2];

  @override
  List<Object?> get props => [last5Months, bookings, occupancy, cancellation];
}
