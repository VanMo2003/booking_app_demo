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
}
