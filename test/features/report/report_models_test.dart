import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> period(String from, String to, {num total = 0}) => {
        'from': from,
        'to': to,
        'totalRevenue': total,
        'roomRevenue': 1200000,
        'serviceRevenue': 1120000,
        'tourRevenue': 0,
        'completedBookings': 2,
        'completedTours': 0,
        'tourGuests': 0,
        'roomNightsSold': 2,
        'availableRoomNights': 400,
        'occupancyRate': 0.5,
        'adr': 600000,
        'revpar': 3000,
        'averagePerBooking': 1160000,
        'totalBookings': 2,
        'canceledBookings': 0,
        'cancellationRate': 0.0,
      };

  test('đọc tổng quan kỳ: KPI, kỳ trước, thanh toán và kênh bán', () {
    final summary = ReportModel.summary({
      'current': period('2026-10-01', '2026-10-20', total: 2320000),
      'previous': period('2026-09-11', '2026-09-30', total: 1546667),
      'revenueGrowth': 50.0,
      'bookingGrowth': 0,
      'occupancyChange': 0.5,
      'byPaymentMethod': [
        {'key': 'CASH', 'count': 1, 'revenue': 1120000, 'share': 48.28},
        {'key': 'VN_PAY', 'count': 1, 'revenue': 1200000, 'share': 51.72},
      ],
      'byChannel': [
        {'key': 'SELF_SERVICE', 'count': 1, 'revenue': 1200000, 'share': 51.72},
      ],
    });

    expect(summary.current.totalRevenue, 2320000);
    expect(summary.current.adr, 600000);
    expect(summary.current.from, DateTime(2026, 10, 1));
    expect(summary.previous.to, DateTime(2026, 9, 30));
    expect(summary.revenueGrowth, 50);
    expect(summary.bookingGrowth, 0);
    expect(summary.byPaymentMethod.map((s) => s.key), ['CASH', 'VN_PAY']);
    expect(summary.byChannel.single.share, 51.72);
  });

  test('BE bỏ trường tăng trưởng khi kỳ trước bằng 0: hiểu là chưa có để so', () {
    final summary = ReportModel.summary({
      'current': period('2026-10-01', '2026-10-20', total: 2320000),
      'previous': period('2026-09-11', '2026-09-30'),
      'occupancyChange': 0.5,
    });

    expect(summary.revenueGrowth, isNull);
    expect(summary.adrGrowth, isNull);
    expect(summary.revparGrowth, isNull);
    expect(summary.occupancyChange, 0.5);
    expect(summary.byPaymentMethod, isEmpty);
  });

  test('đọc doanh thu theo tour: tour đã xoá không có id, đơn AI, tiền phòng gói', () {
    final rows = [
      {
        'tourId': 7,
        'tourName': 'Hạ Long',
        'orders': 2,
        'guests': 4,
        'tourRevenue': 1350000,
        'packageRoomAmount': 1000000,
        'aiOrders': 1,
      },
      {'tourId': null, 'tourName': 'Ninh Bình', 'orders': 1, 'guests': 1, 'tourRevenue': 300000},
    ].map(ReportModel.tour).toList();

    expect(rows.first.tourId, 7);
    expect(rows.first.revenue, 1350000);
    expect(rows.first.aiOrders, 1);
    expect(rows.last.tourId, isNull);
    expect(rows.last.packageRoomAmount, 0);
  });

  test('đọc so sánh cơ sở: KPI kỳ này, tỷ trọng, tăng trưởng có thể vắng', () {
    final rows = [
      {
        'hotelId': 7,
        'hotelName': 'Đà Nẵng',
        'current': period('2026-10-01', '2026-10-20', total: 3000000),
        'previousRevenue': 0,
        'revenueShare': 75.0,
      },
      {
        'hotelId': 6,
        'hotelName': 'Hoàn Kiếm',
        'current': period('2026-10-01', '2026-10-20', total: 1000000),
        'previousRevenue': 500000,
        'revenueGrowth': 100.0,
        'revenueShare': 25.0,
      },
    ].map(ReportModel.branch).toList();

    expect(rows.first.hotelName, 'Đà Nẵng');
    expect(rows.first.current.totalRevenue, 3000000);
    expect(rows.first.revenueGrowth, isNull);
    expect(rows.last.revenueGrowth, 100);
    expect(rows.last.previousRevenue, 500000);
    expect(rows.last.revenueShare, 25);
  });

  test('đọc doanh thu dự kiến: từng ngày, đã thu trước, quá hạn, chưa thu', () {
    final outlook = ReportModel.outlook({
      'from': '2026-10-20',
      'to': '2026-10-22',
      'totalExpected': 2900000,
      'bookingRevenue': 2000000,
      'bookings': 2,
      'prepaidRevenue': 1200000,
      'prepaidBookings': 1,
      'awaitingConfirmationRevenue': 800000,
      'awaitingConfirmationBookings': 1,
      'tourRevenue': 900000,
      'tours': 1,
      'byDate': [
        {'date': '2026-10-20', 'bookingRevenue': 1200000, 'tourRevenue': 0, 'bookings': 1, 'tours': 0},
        {'date': '2026-10-21', 'bookingRevenue': 0, 'tourRevenue': 0, 'bookings': 0, 'tours': 0},
        {'date': '2026-10-22', 'bookingRevenue': 800000, 'tourRevenue': 900000, 'bookings': 1, 'tours': 1},
      ],
      'overdueRevenue': 500000,
      'overdueBookings': 1,
      'outstandingAmount': 300000,
      'outstandingBookings': 1,
    });

    expect(outlook.days, 3);
    expect(outlook.byDate.last.total, 1700000);
    expect(outlook.byDate.last.date, DateTime(2026, 10, 22));
    expect(outlook.prepaidRevenue, 1200000);
    expect(outlook.awaitingConfirmationBookings, 1);
    expect(outlook.overdueBookings, 1);
    expect(outlook.outstandingAmount, 300000);
  });

  test('đọc báo cáo trợ lý AI: bên chưa trả lời thì không có thời gian', () {
    final report = ReportModel.aiAssistant({
      'conversations': 3,
      'aiOnlyConversations': 3,
      'staffConversations': 0,
      'guestMessages': 5,
      'aiReplies': 4,
      'staffReplies': 0,
      'aiReplyShare': 100.0,
      'aiMedianReplySeconds': 7,
      'staffMedianReplySeconds': null,
      'waitingForStaff': 0,
      'aiTourOrders': 1,
      'aiTourOrdersOpen': 1,
      'aiTourOrdersCompleted': 0,
      'aiTourOrdersCanceled': 0,
      'aiTourRevenue': 0,
      'aiTourRevenueShare': 0,
    });

    expect(report.aiMedianReplySeconds, 7);
    expect(report.staffMedianReplySeconds, isNull);
    expect(report.tourOrders, 1);
    expect(report.isEmpty, isFalse);
    expect(ReportStrings.replyTimes(7, null), endsWith('AI 7 giây · nhân viên —'));
  });

  test('thời gian trả lời: giây, phút, giờ, ngày', () {
    expect(ReportStrings.replyDuration(45), '45 giây');
    expect(ReportStrings.replyDuration(750), '13 phút');
    expect(ReportStrings.replyDuration(3600), '1 giờ');
    expect(ReportStrings.replyDuration(7500), '2 giờ 5 phút');
    expect(ReportStrings.replyDuration(3 * 86400 + 100), '3 ngày');
  });
}
