import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/booking_hours_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Map<String, dynamic> json) async {
    tester.view.physicalSize = const Size(390 * 3, 600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BookingHoursCard(hours: ReportModel.bookingHours(json)),
          ),
        ),
      ),
    );
  }

  testWidgets('bảng 7 × 24 vừa khổ điện thoại, nêu giờ đông nhất', (tester) async {
    final cells = [
      for (var day = 0; day < 7; day++) [for (var h = 0; h < 24; h++) day == 5 && h == 20 ? 6 : (h == 9 ? 1 : 0)],
    ];
    await pump(tester, {
      'orders': 13,
      'cells': cells,
      'busiestWeekday': 6,
      'busiestHour': 20,
      'nightShare': 15.4,
    });

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.hoursNote(13)), findsOneWidget);
    expect(find.text(ReportStrings.busiestSlot('Thứ Bảy', 20, '15,4%')), findsOneWidget);
    expect(find.text('CN'), findsOneWidget);
  });

  testWidgets('chưa có đơn', (tester) async {
    await pump(tester, {'orders': 0, 'cells': const [], 'nightShare': 0});

    expect(find.text(ReportStrings.noOrders), findsOneWidget);
  });
}
