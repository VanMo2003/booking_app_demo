import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_entities.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_range.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_views.dart';
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
      'canceledRevenue': 650000,
      'averageStayNights': 2.5,
      'averageLeadDays': 5,
      'serviceAttachRate': total == 4000000 ? 50.0 : 40.0,
      'servicePerBooking': total == 4000000 ? 150000 : 100000,
      'payrollCost': 1000000,
      'grossProfit': total - 1000000,
      'profitMargin': total == 0 ? 0 : (total - 1000000) * 100 / total,
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
        'byCustomerType': [
          {'key': 'NEW', 'count': 1, 'revenue': 1100000, 'share': 35.48},
          {'key': 'RETURNING', 'count': 1, 'revenue': 2000000, 'share': 64.52},
        ],
        'byPaymentTiming': [
          {'key': 'PREPAID', 'count': 1, 'revenue': 2000000, 'share': 64.52},
          {'key': 'AT_STAY', 'count': 0, 'revenue': 0, 'share': 0},
          {'key': 'AFTER_CHECKOUT', 'count': 1, 'revenue': 1100000, 'share': 35.48},
          {'key': 'UNPAID', 'count': 0, 'revenue': 0, 'share': 0},
          {'key': 'UNKNOWN', 'count': 0, 'revenue': 0, 'share': 0},
        ],
        'averageDaysToCollect': 3.0,
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
          'reviews': 12,
          'averageRating': 4.5,
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
  Future<List<RevenueBucket>> trend(ReportScope scope, ReportRange range, RevenueGranularity granularity) async => [
        RevenueBucket(
          start: range.from,
          end: range.from,
          revenue: 3100000,
          bookings: 2,
          tourRevenue: 900000,
          tours: 1,
          payrollCost: 3600000,
          grossProfit: -500000,
        ),
      ];

  // danh sách sửa được, như danh sách đọc từ JSON: use case sắp xếp tại chỗ
  @override
  Future<List<RoomTypeRevenue>> revenueByRoomType(ReportScope scope, ReportRange range) async =>
      [
        ReportModel.roomType({
          'roomTypeName': 'Deluxe',
          'bookedRooms': 2,
          'roomNights': 4,
          'totalRevenue': 2400000,
          'rooms': 3,
          'occupancyRate': 35.0,
          'adr': 600000,
          'revpar': 210000,
          'listPrice': 750000,
        }),
        ReportModel.roomType({
          'roomTypeName': 'Suite',
          'bookedRooms': 0,
          'roomNights': 0,
          'totalRevenue': 0,
          'rooms': 1,
          'occupancyRate': 0,
          'adr': 0,
          'revpar': 0,
          'listPrice': 1500000,
        }),
      ];

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
  Future<OccupancySummary> occupancy(ReportScope scope, ReportRange range) async => ReportModel.occupancy(
        {'totalRooms': 2, 'roomNights': 40, 'occupiedRoomNights': 6, 'occupancyRate': 15.0},
      );

  @override
  Future<List<WeekdayStats>> weekdays(ReportScope scope, ReportRange range) async => [
        for (var day = 1; day <= 7; day++)
          ReportModel.weekday({
            'dayOfWeek': day,
            'days': 3,
            'averageOccupancy': day == 6 ? 80.0 : 20.0,
            'averageRevenue': day == 7 ? 1500000 : 300000,
            'totalRevenue': day == 7 ? 4500000 : 900000,
          }),
      ];

  @override
  Future<List<DailyOccupancy>> occupancyDaily(BranchReportScope scope, ReportRange range) async => [];

  @override
  Future<List<RoomPerformance>> roomPerformance(BranchReportScope scope, ReportRange range) async => [
        ReportModel.room({
          'roomId': 1,
          'roomNumber': '101',
          'roomTypeName': 'Deluxe',
          'price': 600000,
          'occupiedNights': 6,
          'occupancyRate': 30.0,
          'completedStays': 2,
          'revenue': 3600000,
        }),
        ReportModel.room({
          'roomId': 2,
          'roomNumber': '102',
          'roomTypeName': 'Deluxe',
          'price': 600000,
          'occupiedNights': 0,
          'occupancyRate': 0,
          'completedStays': 0,
          'revenue': 0,
        }),
      ];

  @override
  Future<List<TopCustomer>> topCustomers(ReportScope scope, ReportRange range, {int limit = 10}) async => [];

  @override
  Future<List<StaffPerformance>> staffPerformance(ReportScope scope, ReportRange range) async => [];

  @override
  Future<CancellationStats> cancellation(ReportScope scope, ReportRange range) async => ReportModel.cancellation({
        'totalBooking': 10,
        'canceledBooking': 4,
        'completedBooking': 5,
        'cancellationRate': 40.0,
        'byLeadTime': [
          {'key': 'SAME_DAY', 'count': 1, 'revenue': 700000, 'share': 25.0},
          {'key': 'D1_2', 'count': 2, 'revenue': 1300000, 'share': 50.0},
          {'key': 'D3_7', 'count': 0, 'revenue': 0, 'share': 0},
          {'key': 'D8_30', 'count': 1, 'revenue': 450000, 'share': 25.0},
          {'key': 'OVER_30', 'count': 0, 'revenue': 0, 'share': 0},
        ],
        'medianCancelLeadDays': 2,
        'lateCancellations': 3,
        'lateCancellationShare': 75.0,
        'canceledByGuest': 3,
        'canceledByHotel': 1,
      });

  @override
  Future<List<GuestOrigin>> guestOrigins(ReportScope scope, ReportRange range) async => [
        for (var i = 0; i < 10; i++)
          ReportModel.guestOrigin({
            'hometown': i == 9 ? null : 'Tỉnh $i',
            'guests': 10 - i,
            'bookings': 10 - i,
            'tours': i == 0 ? 2 : 0,
            'revenue': (10 - i) * 1000000,
            'share': 10 - i,
          }),
      ];

  @override
  Future<RatingReport> ratings(ReportScope scope, ReportRange range) async => ReportModel.ratings({
        'reviews': 6,
        'averageRating': 3.8,
        'previousAverageRating': 4.2,
        'distribution': [0, 1, 1, 2, 2],
        'reviewRate': 30.0,
        'lowReviews': [
          {
            'feedbackId': 3,
            'bookingId': 21,
            'hotelName': 'Đà Nẵng Riverside',
            'customerName': 'Nguyễn An',
            'rating': 2,
            'comments': 'Phòng ồn, điều hoà kém',
            'reviewDate': '2026-10-15',
          },
        ],
      });

  @override
  Future<AiAssistantReport> aiAssistant(ReportScope scope, ReportRange range) async => ReportModel.aiAssistant({
        'conversations': 12,
        'aiOnlyConversations': 8,
        'staffConversations': 4,
        'guestMessages': 40,
        'aiReplies': 30,
        'staffReplies': 10,
        'aiReplyShare': 75.0,
        'aiMedianReplySeconds': 6,
        'staffMedianReplySeconds': 750,
        'waitingForStaff': 2,
        'aiTourOrders': 5,
        'aiTourOrdersOpen': 2,
        'aiTourOrdersCompleted': 2,
        'aiTourOrdersCanceled': 1,
        'aiTourRevenue': 1800000,
        'aiTourRevenueShare': 40.0,
      });

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

  testWidgets('tab Lấp đầy của cơ sở: từng phòng, phòng chưa có khách', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: ReportsView(scope: BranchReportScope(6), title: ReportStrings.branchReportsTitle),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, ReportStrings.tabOccupancy));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.byRoom), findsOneWidget);
    expect(find.text(ReportStrings.roomLabel('101', 'Deluxe')), findsOneWidget);
    expect(find.text(ReportStrings.roomCaption(6, '3.600.000 ₫')), findsOneWidget);
    expect(find.text(ReportStrings.idleRooms('102')), findsOneWidget);
    expect(find.text(ReportStrings.byWeekday), findsOneWidget);
    expect(
      find.text(ReportStrings.weekdayHighlights('Thứ Bảy', '80%', 'Chủ nhật', '1,5 tr')),
      findsOneWidget,
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
    expect(find.text('2,5 đêm'), findsOneWidget);
    // 4.000.000 doanh thu − 1.000.000 lương
    expect(find.text('3.000.000 ₫'), findsWidgets);
    expect(find.text(ReportStrings.profitMargin('75%')), findsOneWidget);
    expect(find.text('5 ngày'), findsOneWidget);
    // đơn mua dịch vụ: 50% so với 40% kỳ trước = +10 điểm
    expect(find.text(ReportStrings.serviceAttach), findsOneWidget);
    expect(find.text('+10 điểm'), findsOneWidget);
    expect(find.text(ReportStrings.previousValue('100.000 ₫')), findsOneWidget);
    expect(find.text(ReportStrings.canceledLoss(1, 3, '650.000 ₫')), findsOneWidget);
    expect(find.text('+100%'), findsWidgets);
    expect(find.text('−20%'), findsOneWidget);
    expect(find.text('+2,5 điểm'), findsOneWidget);
    expect(find.text(ReportStrings.byPaymentMethod), findsOneWidget);
    expect(find.text(ReportStrings.channelFrontDesk), findsOneWidget);
    expect(find.text(ReportStrings.returningGuests), findsOneWidget);
    // thời điểm thu tiền: chỉ các nhóm có đơn, kèm số ngày thu muộn
    expect(find.text(ReportStrings.paymentTimingLabel('PREPAID')), findsOneWidget);
    expect(find.text(ReportStrings.paymentTimingLabel('UNPAID')), findsNothing);
    expect(find.text(ReportStrings.daysToCollect('3')), findsOneWidget);
    // diễn biến: lãi sau lương của mốc, âm thì báo đỏ
    expect(find.text(ReportStrings.bucketProfit('-500 N')), findsOneWidget);
    // diễn biến: dòng chi tiết có cả số tour
    expect(find.text(ReportStrings.bucketCounts('2 đơn', 1)), findsOneWidget);
    expect(find.text(ReportStrings.branchComparison), findsOneWidget);
    // cơ sở có đánh giá hiện điểm; cơ sở chưa có thì không
    expect(find.text(ReportStrings.branchRating('4,5', 12)), findsOneWidget);
    expect(find.textContaining('đánh giá)'), findsOneWidget);

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

  testWidgets('tab Khách & NV: thẻ trợ lý AI', (tester) async {
    await pumpChainReports(tester);
    // thanh tab cuộn ngang trên điện thoại
    await tester.ensureVisible(find.text(ReportStrings.tabPeople));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ReportStrings.tabPeople));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.aiAssistant), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text(ReportStrings.aiReplies(40, 30, 10)), findsOneWidget);
    expect(find.text(ReportStrings.replyTimes(6, 750)), findsOneWidget);
    expect(find.textContaining('AI 6 giây · nhân viên 13 phút'), findsOneWidget);
    expect(find.text(ReportStrings.aiTours(5, 2, 2, 1)), findsOneWidget);
    expect(find.text(ReportStrings.aiTourRevenue('1.800.000 ₫', '40%')), findsOneWidget);
    expect(find.text(ReportStrings.waitingForStaff(2)), findsOneWidget);

    // đánh giá: điểm, kỳ trước, đánh giá thấp kèm cơ sở (báo cáo chuỗi)
    expect(find.text(ReportStrings.ratingsTitle), findsOneWidget);
    expect(find.text('3,8 ★'), findsOneWidget);
    expect(find.text(ReportStrings.previousRating('4,2')), findsOneWidget);
    expect(find.text('★★☆☆☆  Phòng ồn, điều hoà kém'), findsOneWidget);
    expect(find.text(ReportStrings.reviewLine('Nguyễn An', '15/10/2026', 'Đà Nẵng Riverside')), findsOneWidget);
    // quê quán: 8 nơi đầu, còn lại gộp
    expect(find.text('Tỉnh 0'), findsOneWidget);
    expect(find.text(ReportStrings.originCaption(10, 10, 2, '10%')), findsOneWidget);
    expect(find.text('Tỉnh 8'), findsNothing);
    expect(find.text(ReportStrings.otherOrigins(2, '3.000.000 ₫')), findsOneWidget);

    // huỷ trước ngày nhận phòng bao lâu
    expect(find.text(ReportStrings.cancelLeadTime), findsOneWidget);
    expect(find.text(ReportStrings.cancelLeadLabel('D1_2')), findsOneWidget);
    expect(find.text(ReportStrings.cancelLeadCaption('50%', '1.300.000 ₫')), findsOneWidget);
    expect(find.text(ReportStrings.lateCancellations('75%', 2)), findsOneWidget);
    expect(find.text(ReportStrings.canceledBySide(3, 1)), findsOneWidget);
  });

  testWidgets('tab Cơ cấu: thêm doanh thu theo tour', (tester) async {
    await pumpChainReports(tester);
    await tester.tap(find.text(ReportStrings.tabBreakdown));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.byTour), findsOneWidget);
    // loại phòng: lấp đầy, ADR, RevPAR; bán thấp hơn giá niêm yết 20%; loại chưa bán vẫn có mặt
    expect(
      find.text([
        ReportStrings.roomTypeCounts(3, 2, 4),
        ReportStrings.roomTypeKpis('35%', '600 N', '210 N'),
        ReportStrings.belowListPrice('750 N', '20%'),
      ].join('\n')),
      findsOneWidget,
    );
    expect(find.text('Suite'), findsOneWidget);
    expect(find.text('Vịnh Hạ Long 1 ngày'), findsOneWidget);
    expect(find.textContaining('1 đơn do AI lên'), findsOneWidget);
  });
}
