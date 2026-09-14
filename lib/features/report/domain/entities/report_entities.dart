import 'package:equatable/equatable.dart';

/// Phạm vi báo cáo: một cơ sở hoặc cả chuỗi. Hai phạm vi dùng chung hợp đồng
/// API, chỉ khác tiền tố `/chain` và tên tham số id.
sealed class ReportScope extends Equatable {
  const ReportScope();

  String get pathPrefix;
  Map<String, dynamic> get idQuery;
  String get exportFilePrefix;
}

class BranchReportScope extends ReportScope {
  const BranchReportScope(this.hotelId);

  final int hotelId;

  @override
  String get pathPrefix => '';

  @override
  Map<String, dynamic> get idQuery => {'hotelId': hotelId};

  @override
  String get exportFilePrefix => 'bao-cao-co-so-$hotelId';

  @override
  List<Object?> get props => [hotelId];
}

class ChainReportScope extends ReportScope {
  const ChainReportScope(this.hotelChainId);

  final int hotelChainId;

  @override
  String get pathPrefix => '/chain';

  @override
  Map<String, dynamic> get idQuery => {'hotelChainId': hotelChainId};

  @override
  String get exportFilePrefix => 'bao-cao-chuoi-$hotelChainId';

  @override
  List<Object?> get props => [hotelChainId];
}

class RevenueByDate extends Equatable {
  const RevenueByDate({required this.date, required this.revenue, required this.bookings});

  final DateTime date;
  final double revenue;
  final int bookings;

  @override
  List<Object?> get props => [date, revenue, bookings];
}

class RevenueByWeek extends Equatable {
  const RevenueByWeek({
    required this.year,
    required this.week,
    required this.revenue,
    required this.bookings,
    this.startDate,
    this.endDate,
  });

  final int year;
  final int week;
  final DateTime? startDate;
  final DateTime? endDate;
  final double revenue;
  final int bookings;

  @override
  List<Object?> get props => [year, week, startDate, endDate, revenue, bookings];
}

class RevenueByMonth extends Equatable {
  const RevenueByMonth({
    required this.year,
    required this.month,
    required this.revenue,
    required this.bookings,
  });

  final int year;
  final int month;
  final double revenue;
  final int bookings;

  /// Khoá sắp xếp theo thời gian.
  int get monthIndex => year * 12 + month;

  @override
  List<Object?> get props => [year, month, revenue, bookings];
}

class RevenueByYear extends Equatable {
  const RevenueByYear({required this.year, required this.revenue, required this.bookings});

  final int year;
  final double revenue;
  final int bookings;

  @override
  List<Object?> get props => [year, revenue, bookings];
}

class OccupancySummary extends Equatable {
  const OccupancySummary({
    required this.totalRooms,
    required this.roomNights,
    required this.occupiedRoomNights,
    required this.rate,
  });

  final int totalRooms;
  final int roomNights;
  final int occupiedRoomNights;

  /// Phần trăm, đã làm tròn 2 chữ số phía BE.
  final double rate;

  @override
  List<Object?> get props => [totalRooms, roomNights, occupiedRoomNights, rate];
}

class DailyOccupancy extends Equatable {
  const DailyOccupancy({
    required this.date,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.rate,
  });

  final DateTime date;
  final int totalRooms;
  final int occupiedRooms;
  final double rate;

  @override
  List<Object?> get props => [date, totalRooms, occupiedRooms, rate];
}

class RoomTypeRevenue extends Equatable {
  const RoomTypeRevenue({
    required this.name,
    required this.bookedRooms,
    required this.roomNights,
    required this.revenue,
  });

  final String name;
  final int bookedRooms;
  final int roomNights;
  final double revenue;

  @override
  List<Object?> get props => [name, bookedRooms, roomNights, revenue];
}

class ServiceRevenue extends Equatable {
  const ServiceRevenue({required this.name, required this.quantity, required this.revenue});

  final String name;
  final int quantity;
  final double revenue;

  @override
  List<Object?> get props => [name, quantity, revenue];
}

class TopCustomer extends Equatable {
  const TopCustomer({
    required this.customerId,
    required this.fullName,
    required this.phoneNumber,
    required this.bookings,
    required this.spend,
  });

  final int customerId;
  final String fullName;
  final String phoneNumber;
  final int bookings;
  final double spend;

  @override
  List<Object?> get props => [customerId, fullName, phoneNumber, bookings, spend];
}

class StaffPerformance extends Equatable {
  const StaffPerformance({
    required this.accountId,
    required this.username,
    required this.bookings,
    required this.revenue,
    this.fullName,
    this.positionName,
  });

  final String accountId;
  final String username;
  final String? fullName;
  final String? positionName;
  final int bookings;
  final double revenue;

  @override
  List<Object?> get props => [accountId, username, fullName, positionName, bookings, revenue];
}

class CancellationStats extends Equatable {
  const CancellationStats({
    required this.total,
    required this.canceled,
    required this.completed,
    required this.rate,
  });

  final int total;
  final int canceled;
  final int completed;
  final double rate;

  @override
  List<Object?> get props => [total, canceled, completed, rate];
}
