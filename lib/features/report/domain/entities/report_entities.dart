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

/// Đơn tour hoàn tất của một tour. [packageRoomAmount] chỉ để tham khảo: phòng
/// trong gói là đơn phòng riêng, tính vào doanh thu phòng khi khách trả phòng.
class TourRevenue extends Equatable {
  const TourRevenue({
    required this.name,
    required this.orders,
    required this.guests,
    required this.revenue,
    required this.packageRoomAmount,
    required this.aiOrders,
    this.tourId,
  });

  /// `null` khi tour đã bị xoá — đơn vẫn giữ tên tour.
  final int? tourId;
  final String name;
  final int orders;
  final int guests;
  final double revenue;
  final double packageRoomAmount;

  /// Số đơn do trợ lý AI lên sau khi khách đồng ý trong tin nhắn.
  final int aiOrders;

  @override
  List<Object?> get props => [tourId, name, orders, guests, revenue, packageRoomAmount, aiOrders];
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

/// KPI doanh thu của một kỳ, tính cả hai đầu. Phòng và dịch vụ ghi nhận theo
/// ngày trả phòng của đơn hoàn tất, tour theo ngày đi của đơn tour hoàn tất.
class RevenuePeriod extends Equatable {
  const RevenuePeriod({
    required this.from,
    required this.to,
    required this.totalRevenue,
    required this.roomRevenue,
    required this.serviceRevenue,
    required this.tourRevenue,
    required this.completedBookings,
    required this.completedTours,
    required this.tourGuests,
    required this.roomNightsSold,
    required this.availableRoomNights,
    required this.occupancyRate,
    required this.adr,
    required this.revpar,
    required this.averagePerBooking,
    required this.totalBookings,
    required this.canceledBookings,
    required this.cancellationRate,
    this.canceledRevenue = 0,
    this.averageStayNights = 0,
    this.averageLeadDays = 0,
    this.payrollCost = 0,
    this.grossProfit = 0,
    this.profitMargin = 0,
  });

  final DateTime from;
  final DateTime to;
  final double totalRevenue;
  final double roomRevenue;
  final double serviceRevenue;
  final double tourRevenue;
  final int completedBookings;
  final int completedTours;
  final int tourGuests;
  final int roomNightsSold;
  final int availableRoomNights;
  final double occupancyRate;

  /// Giá phòng bình quân mỗi đêm đã bán.
  final double adr;

  /// Doanh thu phòng trên mỗi đêm phòng khả dụng.
  final double revpar;
  final double averagePerBooking;
  final int totalBookings;
  final int canceledBookings;
  final double cancellationRate;

  /// Giá trị các đơn bị huỷ trong kỳ.
  final double canceledRevenue;

  /// Số đêm trung bình mỗi đơn hoàn tất.
  final double averageStayNights;

  /// Số ngày trung bình từ lúc đặt đến ngày nhận phòng.
  final double averageLeadDays;

  /// Lương đã duyệt/đã trả của nhân viên, chia đều theo ngày trong tháng và
  /// tính phần rơi vào kỳ.
  final double payrollCost;

  /// Tổng doanh thu trừ chi phí lương; có thể âm.
  final double grossProfit;

  /// Lợi nhuận trên doanh thu, phần trăm.
  final double profitMargin;

  @override
  List<Object?> get props => [
        from,
        to,
        totalRevenue,
        roomRevenue,
        serviceRevenue,
        tourRevenue,
        completedBookings,
        completedTours,
        tourGuests,
        roomNightsSold,
        availableRoomNights,
        occupancyRate,
        adr,
        revpar,
        averagePerBooking,
        totalBookings,
        canceledBookings,
        cancellationRate,
        canceledRevenue,
        averageStayNights,
        averageLeadDays,
        payrollCost,
        grossProfit,
        profitMargin,
      ];
}

/// Đơn đã hoàn tất nhưng chưa ghi nhận thanh toán — tiền quầy còn phải thu
/// hoặc xác nhận.
class Receivable extends Equatable {
  const Receivable({
    required this.bookingId,
    required this.hotelId,
    required this.hotelName,
    required this.customerName,
    required this.phoneNumber,
    required this.checkoutDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.daysOverdue,
  });

  final int bookingId;
  final int hotelId;
  final String hotelName;
  final String customerName;
  final String phoneNumber;
  final DateTime checkoutDate;
  final double totalAmount;

  /// Giá trị gốc từ BE (`CASH`, `BANK_TRANSFER`, `VN_PAY`).
  final String paymentMethod;

  /// Số ngày kể từ ngày trả phòng.
  final int daysOverdue;

  @override
  List<Object?> get props => [bookingId, hotelId, customerName, checkoutDate, totalAmount, daysOverdue];
}

/// Doanh thu một tháng so với mục tiêu, của một cơ sở ([hotelId] có giá trị)
/// hoặc cả chuỗi. Dự kiến = doanh thu đã có + đơn và tour đã đặt sẽ hoàn tất
/// trong phần còn lại của tháng.
class TargetProgress extends Equatable {
  const TargetProgress({
    required this.month,
    required this.revenue,
    required this.projectedRevenue,
    required this.daysElapsed,
    required this.daysInMonth,
    this.hotelId,
    this.hotelName,
    this.target,
    this.achievedRate,
    this.projectedRate,
  });

  final int? hotelId;
  final String? hotelName;

  /// "2026-10".
  final String month;

  /// `null` khi chưa đặt mục tiêu.
  final double? target;
  final double revenue;
  final double projectedRevenue;
  final double? achievedRate;
  final double? projectedRate;
  final int daysElapsed;
  final int daysInMonth;

  bool get hasTarget => target != null;

  @override
  List<Object?> get props => [
        hotelId,
        hotelName,
        month,
        target,
        revenue,
        projectedRevenue,
        achievedRate,
        projectedRate,
        daysElapsed,
        daysInMonth,
      ];
}

class ChainTargetProgress extends Equatable {
  const ChainTargetProgress({required this.chain, required this.branches});

  final TargetProgress chain;
  final List<TargetProgress> branches;

  @override
  List<Object?> get props => [chain, branches];
}

/// Một thứ trong tuần (1 = thứ Hai … 7 = Chủ nhật), trung bình trên các ngày
/// của kỳ rơi vào thứ đó.
class WeekdayStats extends Equatable {
  const WeekdayStats({
    required this.dayOfWeek,
    required this.days,
    required this.averageOccupancy,
    required this.averageRevenue,
    required this.totalRevenue,
  });

  final int dayOfWeek;
  final int days;
  final double averageOccupancy;

  /// Doanh thu mỗi ngày (đơn phòng theo ngày trả phòng, tour theo ngày đi).
  final double averageRevenue;
  final double totalRevenue;

  @override
  List<Object?> get props => [dayOfWeek, days, averageOccupancy, averageRevenue, totalRevenue];
}

/// Một phòng của cơ sở trong khoảng đang xem.
class RoomPerformance extends Equatable {
  const RoomPerformance({
    required this.roomId,
    required this.roomNumber,
    required this.roomTypeName,
    required this.price,
    required this.occupiedNights,
    required this.occupancyRate,
    required this.completedStays,
    required this.revenue,
  });

  final int roomId;
  final String roomNumber;
  final String roomTypeName;
  final double price;

  /// Số đêm trong kỳ có đơn chưa huỷ.
  final int occupiedNights;
  final double occupancyRate;

  /// Lượt ở đã hoàn tất, trả phòng trong kỳ.
  final int completedStays;

  /// Giá phòng × số đêm của các lượt hoàn tất.
  final double revenue;

  bool get idle => occupiedNights == 0;

  @override
  List<Object?> get props =>
      [roomId, roomNumber, roomTypeName, price, occupiedNights, occupancyRate, completedStays, revenue];
}

/// Doanh thu dự kiến của một ngày: đơn mở trả phòng hôm đó, tour mở khởi hành hôm đó.
class ExpectedRevenue extends Equatable {
  const ExpectedRevenue({
    required this.date,
    required this.bookingRevenue,
    required this.tourRevenue,
    required this.bookings,
    required this.tours,
  });

  final DateTime date;
  final double bookingRevenue;
  final double tourRevenue;
  final int bookings;
  final int tours;

  double get total => bookingRevenue + tourRevenue;

  @override
  List<Object?> get props => [date, bookingRevenue, tourRevenue, bookings, tours];
}

/// Doanh thu sắp tới (từ hôm nay) và tiền còn phải thu. "Mở" là chờ xác nhận
/// hoặc đã xác nhận; đơn tính vào ngày trả phòng, tour vào ngày đi.
class RevenueOutlook extends Equatable {
  const RevenueOutlook({
    required this.from,
    required this.to,
    required this.totalExpected,
    required this.bookingRevenue,
    required this.bookings,
    required this.prepaidRevenue,
    required this.prepaidBookings,
    required this.awaitingConfirmationRevenue,
    required this.awaitingConfirmationBookings,
    required this.tourRevenue,
    required this.tours,
    required this.byDate,
    required this.overdueRevenue,
    required this.overdueBookings,
    required this.outstandingAmount,
    required this.outstandingBookings,
  });

  final DateTime from;
  final DateTime to;
  final double totalExpected;
  final double bookingRevenue;
  final int bookings;

  /// Phần khách đã thanh toán trước.
  final double prepaidRevenue;
  final int prepaidBookings;

  /// Phần cơ sở chưa xác nhận — kém chắc chắn nhất.
  final double awaitingConfirmationRevenue;
  final int awaitingConfirmationBookings;
  final double tourRevenue;
  final int tours;
  final List<ExpectedRevenue> byDate;

  /// Đơn còn mở dù đã qua ngày trả phòng.
  final double overdueRevenue;
  final int overdueBookings;

  /// Đơn đã hoàn tất nhưng chưa ghi nhận thanh toán.
  final double outstandingAmount;
  final int outstandingBookings;

  int get days => byDate.length;

  @override
  List<Object?> get props => [
        from,
        to,
        totalExpected,
        bookingRevenue,
        bookings,
        prepaidRevenue,
        prepaidBookings,
        awaitingConfirmationRevenue,
        awaitingConfirmationBookings,
        tourRevenue,
        tours,
        byDate,
        overdueRevenue,
        overdueBookings,
        outstandingAmount,
        outstandingBookings,
      ];
}

/// Một cơ sở của chuỗi trong khoảng đang xem, đặt cạnh kỳ trước của chính nó.
class BranchPerformance extends Equatable {
  const BranchPerformance({
    required this.hotelId,
    required this.hotelName,
    required this.current,
    required this.previousRevenue,
    required this.revenueShare,
    this.revenueGrowth,
  });

  final int hotelId;
  final String hotelName;
  final RevenuePeriod current;
  final double previousRevenue;

  /// `null` khi kỳ trước cơ sở chưa có doanh thu.
  final double? revenueGrowth;

  /// Phần trăm doanh thu của cả chuỗi, 0–100.
  final double revenueShare;

  @override
  List<Object?> get props =>
      [hotelId, hotelName, current, previousRevenue, revenueGrowth, revenueShare];
}

/// Một phần doanh thu: theo phương thức thanh toán hoặc theo kênh bán.
class RevenueShare extends Equatable {
  const RevenueShare({
    required this.key,
    required this.count,
    required this.revenue,
    required this.share,
  });

  /// `CASH` / `BANK_TRANSFER` / `VN_PAY` hoặc `SELF_SERVICE` / `FRONT_DESK` / `TOUR`.
  final String key;
  final int count;
  final double revenue;

  /// Phần trăm trên tổng các phần, 0–100.
  final double share;

  @override
  List<Object?> get props => [key, count, revenue, share];
}

/// Kỳ đang xem đặt cạnh kỳ trước do BE chọn theo lịch: tháng (hoặc từ đầu
/// tháng) so với cùng ngày tháng trước, từ đầu năm so với cùng kỳ năm trước,
/// khoảng khác so với cùng số ngày ngay trước đó. Mức tăng trưởng là phần
/// trăm, `null` khi kỳ trước không có gì để so.
class RevenueSummary extends Equatable {
  const RevenueSummary({
    required this.current,
    required this.previous,
    required this.byPaymentMethod,
    required this.byChannel,
    this.byCustomerType = const [],
    this.revenueGrowth,
    this.bookingGrowth,
    this.adrGrowth,
    this.revparGrowth,
    this.profitGrowth,
    this.occupancyChange,
  });

  final RevenuePeriod current;
  final RevenuePeriod previous;
  final double? revenueGrowth;
  final double? bookingGrowth;
  final double? adrGrowth;
  final double? revparGrowth;

  /// Chỉ có khi kỳ trước có lãi.
  final double? profitGrowth;

  /// Chênh lệch lấp đầy, tính bằng điểm phần trăm.
  final double? occupancyChange;
  final List<RevenueShare> byPaymentMethod;
  final List<RevenueShare> byChannel;

  /// `NEW` / `RETURNING`: khách quay lại là khách đã có đơn hoàn tất trả phòng trước kỳ.
  final List<RevenueShare> byCustomerType;

  @override
  List<Object?> get props => [
        current,
        previous,
        revenueGrowth,
        bookingGrowth,
        adrGrowth,
        revparGrowth,
        profitGrowth,
        occupancyChange,
        byPaymentMethod,
        byChannel,
        byCustomerType,
      ];
}
