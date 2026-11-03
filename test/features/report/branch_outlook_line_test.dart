import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/branch_outlook_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Map<String, dynamic> json) async {
    tester.view.physicalSize = const Size(390 * 3, 300 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: 220, child: BranchOutlookLine(outlook: ReportModel.branchOutlook(json))),
          ),
        ),
      ),
    );
  }

  testWidgets('đã đặt những ngày tới, cạnh mức năm trước nếu có', (tester) async {
    await pump(tester, {
      'hotelId': 6,
      'hotelName': 'Hoàn Kiếm Palace',
      'totalRooms': 20,
      'bookedRoomNights': 72,
      'availableRoomNights': 600,
      'occupancyOnTheBooks': 12.0,
      'lastYearOccupancy': 40.5,
      'totalExpected': 9000000,
    });
    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.branchOnTheBooks(30, '12%', '40,5%')), findsOneWidget);

    await pump(tester, {
      'hotelId': 7,
      'hotelName': 'Thanh Xuân Grand',
      'totalRooms': 19,
      'bookedRoomNights': 0,
      'availableRoomNights': 570,
      'occupancyOnTheBooks': 0,
      'lastYearOccupancy': null,
      'totalExpected': 0,
    });
    expect(find.text(ReportStrings.branchOnTheBooks(30, '0%', null)), findsOneWidget);
    expect(find.textContaining('năm trước'), findsNothing);
  });
}
