import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/report_entities.dart';

/// Chuyển JSON các DTO báo cáo phía BE sang entity.
abstract final class ReportModel {
  static RevenueByDate byDate(Json json) => RevenueByDate(
        date: json.date('date') ?? DateOnly.today(),
        revenue: json.decimal('totalRevenue'),
        bookings: json.integer('totalBooking'),
      );

  static RevenueByWeek byWeek(Json json) => RevenueByWeek(
        year: json.integer('year'),
        week: json.integer('week'),
        startDate: json.date('startDate'),
        endDate: json.date('endDate'),
        revenue: json.decimal('totalRevenue'),
        bookings: json.integer('totalBooking'),
      );

  static RevenueByMonth byMonth(Json json) => RevenueByMonth(
        year: json.integer('year'),
        month: json.integer('month'),
        revenue: json.decimal('totalRevenue'),
        bookings: json.integer('totalBooking'),
      );

  static RevenueByYear byYear(Json json) => RevenueByYear(
        year: json.integer('year'),
        revenue: json.decimal('totalRevenue'),
        bookings: json.integer('totalBooking'),
      );

  static OccupancySummary occupancy(Json json) => OccupancySummary(
        totalRooms: json.integer('totalRooms'),
        roomNights: json.integer('roomNights'),
        occupiedRoomNights: json.integer('occupiedRoomNights'),
        rate: json.decimal('occupancyRate'),
      );

  static DailyOccupancy dailyOccupancy(Json json) => DailyOccupancy(
        date: json.date('date') ?? DateOnly.today(),
        totalRooms: json.integer('totalRooms'),
        occupiedRooms: json.integer('occupiedRooms'),
        rate: json.decimal('occupancyRate'),
      );

  static RoomTypeRevenue roomType(Json json) => RoomTypeRevenue(
        name: json.str('roomTypeName'),
        bookedRooms: json.integer('bookedRooms'),
        roomNights: json.integer('roomNights'),
        revenue: json.decimal('totalRevenue'),
      );

  static ServiceRevenue service(Json json) => ServiceRevenue(
        name: json.str('serviceName'),
        quantity: json.integer('totalQuantity'),
        revenue: json.decimal('totalRevenue'),
      );

  static TopCustomer topCustomer(Json json) => TopCustomer(
        customerId: json.integer('customerId'),
        fullName: json.str('fullName'),
        phoneNumber: json.str('phoneNumber'),
        bookings: json.integer('totalBooking'),
        spend: json.decimal('totalSpend'),
      );

  static StaffPerformance staff(Json json) => StaffPerformance(
        accountId: json.str('accountId'),
        username: json.str('username'),
        fullName: json.strOrNull('fullName'),
        positionName: json.strOrNull('positionName'),
        bookings: json.integer('totalBooking'),
        revenue: json.decimal('totalRevenue'),
      );

  static CancellationStats cancellation(Json json) => CancellationStats(
        total: json.integer('totalBooking'),
        canceled: json.integer('canceledBooking'),
        completed: json.integer('completedBooking'),
        rate: json.decimal('cancellationRate'),
      );
}
