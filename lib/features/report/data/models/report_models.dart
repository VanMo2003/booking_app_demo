import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_views.dart';

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
        rooms: json.integer('rooms'),
        occupancyRate: json.decimal('occupancyRate'),
        adr: json.decimal('adr'),
        revpar: json.decimal('revpar'),
        listPrice: json.decimal('listPrice'),
      );

  static ServiceRevenue service(Json json) => ServiceRevenue(
        name: json.str('serviceName'),
        quantity: json.integer('totalQuantity'),
        revenue: json.decimal('totalRevenue'),
      );

  static TourRevenue tour(Json json) => TourRevenue(
        tourId: json.intOrNull('tourId'),
        name: json.str('tourName'),
        orders: json.integer('orders'),
        guests: json.integer('guests'),
        revenue: json.decimal('tourRevenue'),
        packageRoomAmount: json.decimal('packageRoomAmount'),
        aiOrders: json.integer('aiOrders'),
      );

  static TopCustomer topCustomer(Json json) => TopCustomer(
        customerId: json.integer('customerId'),
        fullName: json.str('fullName'),
        phoneNumber: json.str('phoneNumber'),
        bookings: json.integer('totalBooking'),
        spend: json.decimal('totalSpend'),
        tours: json.integer('tours'),
      );

  static StaffPerformance staff(Json json) => StaffPerformance(
        accountId: json.str('accountId'),
        username: json.str('username'),
        fullName: json.strOrNull('fullName'),
        positionName: json.strOrNull('positionName'),
        bookings: json.integer('totalBooking'),
        revenue: json.decimal('totalRevenue'),
        completedBookings: json.integer('completedBookings'),
        completedRevenue: json.decimal('completedRevenue'),
        toursHandled: json.integer('toursHandled'),
        tourRevenue: json.decimal('tourRevenue'),
      );

  static CancellationStats cancellation(Json json) => CancellationStats(
        total: json.integer('totalBooking'),
        canceled: json.integer('canceledBooking'),
        completed: json.integer('completedBooking'),
        rate: json.decimal('cancellationRate'),
        canceledRevenue: json.decimal('canceledRevenue'),
        canceledSelfService: json.integer('canceledSelfService'),
        canceledFrontDesk: json.integer('canceledFrontDesk'),
        tourOrders: json.integer('tourOrders'),
        tourCanceled: json.integer('tourCanceled'),
        tourCanceledByGuest: json.integer('tourCanceledByGuest'),
        tourCanceledByHotel: json.integer('tourCanceledByHotel'),
        tourRate: json.decimal('tourCancellationRate'),
        byLeadTime: json.listOf('byLeadTime', share),
        medianLeadDays: json.intOrNull('medianCancelLeadDays'),
        lateCancellations: json.integer('lateCancellations'),
        lateShare: json.decimal('lateCancellationShare'),
        canceledByGuest: json.integer('canceledByGuest'),
        canceledByHotel: json.integer('canceledByHotel'),
      );

  static AiAssistantReport aiAssistant(Json json) => AiAssistantReport(
        conversations: json.integer('conversations'),
        aiOnlyConversations: json.integer('aiOnlyConversations'),
        staffConversations: json.integer('staffConversations'),
        guestMessages: json.integer('guestMessages'),
        aiReplies: json.integer('aiReplies'),
        staffReplies: json.integer('staffReplies'),
        aiReplyShare: json.decimal('aiReplyShare'),
        aiMedianReplySeconds: json.intOrNull('aiMedianReplySeconds'),
        staffMedianReplySeconds: json.intOrNull('staffMedianReplySeconds'),
        waitingForStaff: json.integer('waitingForStaff'),
        tourOrders: json.integer('aiTourOrders'),
        tourOrdersOpen: json.integer('aiTourOrdersOpen'),
        tourOrdersCompleted: json.integer('aiTourOrdersCompleted'),
        tourOrdersCanceled: json.integer('aiTourOrdersCanceled'),
        tourRevenue: json.decimal('aiTourRevenue'),
        tourRevenueShare: json.decimal('aiTourRevenueShare'),
      );

  static RevenuePeriod period(Json json) => RevenuePeriod(
        from: json.date('from') ?? DateOnly.today(),
        to: json.date('to') ?? DateOnly.today(),
        totalRevenue: json.decimal('totalRevenue'),
        roomRevenue: json.decimal('roomRevenue'),
        serviceRevenue: json.decimal('serviceRevenue'),
        tourRevenue: json.decimal('tourRevenue'),
        completedBookings: json.integer('completedBookings'),
        completedTours: json.integer('completedTours'),
        tourGuests: json.integer('tourGuests'),
        roomNightsSold: json.integer('roomNightsSold'),
        availableRoomNights: json.integer('availableRoomNights'),
        occupancyRate: json.decimal('occupancyRate'),
        adr: json.decimal('adr'),
        revpar: json.decimal('revpar'),
        averagePerBooking: json.decimal('averagePerBooking'),
        totalBookings: json.integer('totalBookings'),
        canceledBookings: json.integer('canceledBookings'),
        cancellationRate: json.decimal('cancellationRate'),
        canceledRevenue: json.decimal('canceledRevenue'),
        averageStayNights: json.decimal('averageStayNights'),
        averageLeadDays: json.decimal('averageLeadDays'),
        serviceAttachRate: json.decimal('serviceAttachRate'),
        servicePerBooking: json.decimal('servicePerBooking'),
        payrollCost: json.decimal('payrollCost'),
        grossProfit: json.decimal('grossProfit'),
        profitMargin: json.decimal('profitMargin'),
      );

  static RevenueBucket trendBucket(Json json) => RevenueBucket(
        start: json.date('start') ?? DateOnly.today(),
        end: json.date('end') ?? DateOnly.today(),
        revenue: json.decimal('totalRevenue'),
        bookings: json.integer('bookings'),
        week: json.intOrNull('week'),
        tourRevenue: json.decimal('tourRevenue'),
        tours: json.integer('tours'),
      );

  static Receivable receivable(Json json) => Receivable(
        bookingId: json.integer('bookingId'),
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        customerName: json.str('customerName'),
        phoneNumber: json.str('phoneNumber'),
        checkoutDate: json.date('checkoutDate') ?? DateOnly.today(),
        totalAmount: json.decimal('totalAmount'),
        paymentMethod: json.str('paymentMethod'),
        daysOverdue: json.integer('daysOverdue'),
      );

  static TargetProgress target(Json json) => TargetProgress(
        hotelId: json.intOrNull('hotelId'),
        hotelName: json.strOrNull('hotelName'),
        month: json.str('month'),
        target: json.decimalOrNull('target'),
        revenue: json.decimal('revenue'),
        projectedRevenue: json.decimal('projectedRevenue'),
        achievedRate: json.decimalOrNull('achievedRate'),
        projectedRate: json.decimalOrNull('projectedRate'),
        daysElapsed: json.integer('daysElapsed'),
        daysInMonth: json.integer('daysInMonth'),
      );

  static ChainTargetProgress chainTarget(Json json) => ChainTargetProgress(
        chain: target(json.obj('chain') ?? const {}),
        branches: json.listOf('branches', target),
      );

  static WeekdayStats weekday(Json json) => WeekdayStats(
        dayOfWeek: json.integer('dayOfWeek'),
        days: json.integer('days'),
        averageOccupancy: json.decimal('averageOccupancy'),
        averageRevenue: json.decimal('averageRevenue'),
        totalRevenue: json.decimal('totalRevenue'),
      );

  static RoomPerformance room(Json json) => RoomPerformance(
        roomId: json.integer('roomId'),
        roomNumber: json.str('roomNumber'),
        roomTypeName: json.str('roomTypeName'),
        price: json.decimal('price'),
        occupiedNights: json.integer('occupiedNights'),
        occupancyRate: json.decimal('occupancyRate'),
        completedStays: json.integer('completedStays'),
        revenue: json.decimal('revenue'),
      );

  static ExpectedRevenue expected(Json json) => ExpectedRevenue(
        date: json.date('date') ?? DateOnly.today(),
        bookingRevenue: json.decimal('bookingRevenue'),
        tourRevenue: json.decimal('tourRevenue'),
        bookings: json.integer('bookings'),
        tours: json.integer('tours'),
        bookedRooms: json.integer('bookedRooms'),
        occupancyRate: json.decimal('occupancyRate'),
      );

  static RevenueOutlook outlook(Json json) => RevenueOutlook(
        from: json.date('from') ?? DateOnly.today(),
        to: json.date('to') ?? DateOnly.today(),
        totalExpected: json.decimal('totalExpected'),
        bookingRevenue: json.decimal('bookingRevenue'),
        bookings: json.integer('bookings'),
        prepaidRevenue: json.decimal('prepaidRevenue'),
        prepaidBookings: json.integer('prepaidBookings'),
        awaitingConfirmationRevenue: json.decimal('awaitingConfirmationRevenue'),
        awaitingConfirmationBookings: json.integer('awaitingConfirmationBookings'),
        tourRevenue: json.decimal('tourRevenue'),
        tours: json.integer('tours'),
        byDate: json.listOf('byDate', expected),
        overdueRevenue: json.decimal('overdueRevenue'),
        overdueBookings: json.integer('overdueBookings'),
        outstandingAmount: json.decimal('outstandingAmount'),
        outstandingBookings: json.integer('outstandingBookings'),
        totalRooms: json.integer('totalRooms'),
        bookedRoomNights: json.integer('bookedRoomNights'),
        availableRoomNights: json.integer('availableRoomNights'),
        occupancyOnTheBooks: json.decimal('occupancyOnTheBooks'),
        lastYearOccupancy: json.decimalOrNull('lastYearOccupancy'),
      );

  static BranchOutlook branchOutlook(Json json) => BranchOutlook(
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        totalRooms: json.integer('totalRooms'),
        bookedRoomNights: json.integer('bookedRoomNights'),
        availableRoomNights: json.integer('availableRoomNights'),
        occupancyOnTheBooks: json.decimal('occupancyOnTheBooks'),
        lastYearOccupancy: json.decimalOrNull('lastYearOccupancy'),
        totalExpected: json.decimal('totalExpected'),
      );

  static BranchPerformance branch(Json json) => BranchPerformance(
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        current: period(json.obj('current') ?? const {}),
        previousRevenue: json.decimal('previousRevenue'),
        revenueGrowth: json.decimalOrNull('revenueGrowth'),
        revenueShare: json.decimal('revenueShare'),
      );

  static RevenueShare share(Json json) => RevenueShare(
        key: json.str('key'),
        count: json.integer('count'),
        revenue: json.decimal('revenue'),
        share: json.decimal('share'),
      );

  static RevenueSummary summary(Json json) => RevenueSummary(
        current: period(json.obj('current') ?? const {}),
        previous: period(json.obj('previous') ?? const {}),
        revenueGrowth: json.decimalOrNull('revenueGrowth'),
        bookingGrowth: json.decimalOrNull('bookingGrowth'),
        adrGrowth: json.decimalOrNull('adrGrowth'),
        revparGrowth: json.decimalOrNull('revparGrowth'),
        profitGrowth: json.decimalOrNull('profitGrowth'),
        occupancyChange: json.decimalOrNull('occupancyChange'),
        byPaymentMethod: json.listOf('byPaymentMethod', share),
        byChannel: json.listOf('byChannel', share),
        byCustomerType: json.listOf('byCustomerType', share),
      );
}
