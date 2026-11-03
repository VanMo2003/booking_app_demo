import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/revenue_outlook_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// [booked]: số phòng đã đặt của từng đêm đầu khoảng (các đêm sau trống).
Map<String, dynamic> _outlook({int overdue = 0, int outstanding = 0, int rooms = 0, List<int> booked = const []}) => {
      'from': '2026-10-20',
      'to': '2026-11-18',
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
        for (var day = 0; day < 30; day++)
          {
            'date': DateTime(2026, 10, 20 + day).toIso8601String().substring(0, 10),
            'bookingRevenue': day == 0 ? 1200000 : (day == 2 ? 800000 : 0),
            'tourRevenue': day == 2 ? 900000 : 0,
            'bookings': day == 0 || day == 2 ? 1 : 0,
            'tours': day == 2 ? 1 : 0,
            'bookedRooms': day < booked.length ? booked[day] : 0,
            'occupancyRate': day < booked.length && rooms > 0 ? booked[day] * 100 / rooms : 0,
          },
      ],
      'totalRooms': rooms,
      'bookedRoomNights': booked.fold<int>(0, (sum, n) => sum + n),
      'availableRoomNights': rooms * 30,
      'occupancyOnTheBooks': rooms == 0 ? 0 : booked.fold<int>(0, (sum, n) => sum + n) * 100 / (rooms * 30),
      'overdueRevenue': overdue * 500000,
      'overdueBookings': overdue,
      'outstandingAmount': outstanding * 300000,
      'outstandingBookings': outstanding,
    };

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(
    WidgetTester tester,
    Map<String, dynamic> json, {
    VoidCallback? onOpenOverdue,
    VoidCallback? onOpenOutstanding,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RevenueOutlookCard(
              outlook: ReportModel.outlook(json),
              onOpenOverdue: onOpenOverdue,
              onOpenOutstanding: onOpenOutstanding,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('30 ngày tới: tổng dự kiến, phần chờ xác nhận, không có cảnh báo khi mọi thứ ổn', (tester) async {
    await pump(tester, _outlook());

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.outlookTitle(30)), findsOneWidget);
    expect(find.text('2.900.000 ₫'), findsOneWidget);
    expect(find.text(ReportStrings.awaitingConfirmation('800.000 ₫', 1)), findsOneWidget);
    expect(find.textContaining('quá ngày trả phòng'), findsNothing);
    expect(find.textContaining('chưa ghi nhận thanh toán'), findsNothing);
  });

  testWidgets('phòng đã được đặt: lấp đầy cả khoảng, đêm kín phòng', (tester) async {
    await pump(tester, _outlook(rooms: 4, booked: [4, 2]));

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.onTheBooks), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(
      find.text('${ReportStrings.onTheBooksNote(6, 120)} · ${ReportStrings.fullNights(1)}'),
      findsOneWidget,
    );
  });

  testWidgets('chưa kín đêm nào thì nêu đêm đông nhất; chưa ai đặt thì nói rõ', (tester) async {
    await pump(tester, _outlook(rooms: 4, booked: [1, 3]));
    expect(
      find.text('${ReportStrings.onTheBooksNote(4, 120)} · ${ReportStrings.busiestNight('T4, 21/10', 3, 4)}'),
      findsOneWidget,
    );

    await pump(tester, _outlook(rooms: 4));
    expect(find.text(ReportStrings.noBookedRooms(30)), findsOneWidget);
    expect(find.text(ReportStrings.onTheBooks), findsNothing);
  });

  testWidgets('có đơn quá hạn trả phòng và tiền chưa thu thì hiện cảnh báo', (tester) async {
    await pump(tester, _outlook(overdue: 2, outstanding: 1));

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.overdueStays(2, '1.000.000 ₫')), findsOneWidget);
    expect(find.text(ReportStrings.outstandingPayments(1, '300.000 ₫')), findsOneWidget);
  });

  testWidgets('mỗi cảnh báo mở đúng nơi xử lý: quá hạn → quầy, chưa thu → danh sách tiền chưa thu', (tester) async {
    final opened = <String>[];
    await pump(
      tester,
      _outlook(overdue: 1, outstanding: 1),
      onOpenOverdue: () => opened.add('desk'),
      onOpenOutstanding: () => opened.add('receivables'),
    );

    await tester.tap(find.text(ReportStrings.outstandingPayments(1, '300.000 ₫')));
    await tester.tap(find.text(ReportStrings.overdueStays(1, '500.000 ₫')));
    expect(opened, ['receivables', 'desk']);
  });
}
