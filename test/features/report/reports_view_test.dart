import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_entities.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_range.dart';
import 'package:booking_app_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:booking_app_mobile/features/report/domain/usecases/report_usecases.dart';
import 'package:booking_app_mobile/features/report/presentation/reports/reports_cubit.dart';
import 'package:booking_app_mobile/features/report/presentation/reports/reports_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _period({required num total, num tours = 0}) => {
      'from': '2026-10-01',
      'to': '2026-10-20',
      'totalRevenue': total,
      'roomRevenue': total - tours,
      'serviceRevenue': 0,
      'tourRevenue': tours,
      'completedBookings': 2,
      'completedTours': tours > 0 ? 1 : 0,
      'tourGuests': tours > 0 ? 2 : 0,
      'roomNightsSold': 4,
      'availableRoomNights': 400,
      'occupancyRate': 12.5,
      'adr': 600000,
      'revpar': 6000,
      'averagePerBooking': 1000000,
      'totalBookings': 3,
      'canceledBookings': 1,
      'cancellationRate': 33.33,
    };

/// Số liệu mẫu cho một chuỗi hai cơ sở; các báo cáo màn này không mở thì không cần.
class _FakeReports implements ReportRepository {
  @override
  Future<RevenueSummary> summary(ReportScope scope, ReportRange range) async => ReportModel.summary({
        'current': _period(total: 4000000, tours: 900000),
        'previous': _period(total: 2000000),
        'revenueGrowth': 100.0,
        'bookingGrowth': -20.0,
        'adrGrowth': 0,
        'occupancyChange': 2.5,
        'byPaymentMethod': [
          {'key': 'CASH', 'count': 1, 'revenue': 1100000, 'share': 35.48},
          {'key': 'BANK_TRANSFER', 'count': 0, 'revenue': 0, 'share': 0},
          {'key': 'VN_PAY', 'count': 1, 'revenue': 2000000, 'share': 64.52},
        ],
        'byChannel': [
          {'key': 'SELF_SERVICE', 'count': 1, 'revenue': 2000000, 'share': 50},
          {'key': 'FRONT_DESK', 'count': 1, 'revenue': 1100000, 'share': 27.5},
          {'key': 'TOUR', 'count': 1, 'revenue': 900000, 'share': 22.5},
        ],
      });

  @override
  Future<List<BranchPerformance>> branchPerformance(ChainReportScope scope, ReportRange range) async => [
        ReportModel.branch({
          'hotelId': 6,
          'hotelName': 'Khách Sạn Hoàn Kiếm Palace',
          'current': _period(total: 3000000, tours: 900000),
          'previousRevenue': 1500000,
          'revenueGrowth': 100.0,
          'revenueShare': 75.0,
        }),
        ReportModel.branch({
          'hotelId': 7,
          'hotelName': 'Đà Nẵng Riverside',
          'current': {..._period(total: 1000000), 'occupancyRate': 60.0},
          'previousRevenue': 0,
          'revenueShare': 25.0,
        }),
      ];

  @override
  Future<List<RevenueByDate>> revenueByDay(ReportScope scope, ReportRange range) async =>
      [RevenueByDate(date: range.from, revenue: 3100000, bookings: 2)];

  // danh sách sửa được, như danh sách đọc từ JSON: use case sắp xếp tại chỗ
  @override
  Future<List<RoomTypeRevenue>> revenueByRoomType(ReportScope scope, ReportRange range) async =>
      [const RoomTypeRevenue(name: 'Deluxe', bookedRooms: 2, roomNights: 4, revenue: 2400000)];

  @override
  Future<List<ServiceRevenue>> revenueByService(ReportScope scope, ReportRange range) async =>
      [const ServiceRevenue(name: 'Ăn sáng', quantity: 3, revenue: 300000)];

  @override
  Future<List<TourRevenue>> revenueByTour(ReportScope scope, ReportRange range) async => [
        const TourRevenue(
          tourId: 7,
          name: 'Vịnh Hạ Long 1 ngày',
          orders: 1,
          guests: 2,
          revenue: 900000,
          packageRoomAmount: 550000,
          aiOrders: 1,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final fake = _FakeReports();
    getIt.registerFactory<ReportsCubit>(
      () => ReportsCubit(
        LoadRevenueReport(fake),
        LoadRevenueSummary(fake),
        LoadOccupancyReport(fake),
        LoadBreakdownReport(fake),
        LoadPeopleReport(fake),
        ExportReport(fake),
        LoadBranchComparison(fake),
      ),
    );
  });

  Future<void> pumpChainReports(WidgetTester tester) async {
    // khổ điện thoại, đủ cao để danh sách dựng hết các thẻ
    tester.view.physicalSize = const Size(390 * 3, 4200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: ReportsView(scope: ChainReportScope(10), title: ReportStrings.chainReportsTitle),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tab Doanh thu của chuỗi: tổng quan, thanh toán, kênh bán, so sánh cơ sở', (tester) async {
    await pumpChainReports(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('4.000.000 ₫'), findsOneWidget);
    // chi tiết cơ cấu hiện trọn vẹn trên dòng riêng
    expect(find.text(ReportStrings.soldNights(4)), findsOneWidget);
    expect(find.text(ReportStrings.tourOrders(1, 2)), findsOneWidget);
    expect(find.text('+100%'), findsWidgets);
    expect(find.text('−20%'), findsOneWidget);
    expect(find.text('+2,5 điểm'), findsOneWidget);
    expect(find.text(ReportStrings.byPaymentMethod), findsOneWidget);
    expect(find.text(ReportStrings.channelFrontDesk), findsOneWidget);
    expect(find.text(ReportStrings.branchComparison), findsOneWidget);

    // xếp theo doanh thu: Hoàn Kiếm trước; theo lấp đầy: Đà Nẵng (60%) trước
    double top(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(top('Khách Sạn Hoàn Kiếm Palace'), lessThan(top('Đà Nẵng Riverside')));
    // "Lấp đầy" còn là tên tab và nhãn KPI; chỉ chip xếp hạng là ChoiceChip
    final occupancyChip = find.widgetWithText(ChoiceChip, ReportStrings.sortOccupancy);
    // hàng chip cuộn ngang trên điện thoại
    await tester.ensureVisible(occupancyChip);
    await tester.pumpAndSettle();
    await tester.tap(occupancyChip);
    await tester.pumpAndSettle();
    expect(top('Đà Nẵng Riverside'), lessThan(top('Khách Sạn Hoàn Kiếm Palace')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab Cơ cấu: thêm doanh thu theo tour', (tester) async {
    await pumpChainReports(tester);
    await tester.tap(find.text(ReportStrings.tabBreakdown));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.byTour), findsOneWidget);
    expect(find.text('Vịnh Hạ Long 1 ngày'), findsOneWidget);
    expect(find.textContaining('1 đơn do AI lên'), findsOneWidget);
  });
}
