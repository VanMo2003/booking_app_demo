import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/today_collections_card.dart';
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
            child: TodayCollectionsCard(collections: ReportModel.collections(json)),
          ),
        ),
      ),
    );
  }

  testWidgets('hôm nay đã thu: tổng, số khoản, từng phương thức có thu', (tester) async {
    await pump(tester, {
      'total': 12500000,
      'payments': 3,
      'byMethod': [
        {'key': 'CASH', 'count': 2, 'revenue': 4500000, 'share': 36},
        {'key': 'BANK_TRANSFER', 'count': 0, 'revenue': 0, 'share': 0},
        {'key': 'VN_PAY', 'count': 1, 'revenue': 8000000, 'share': 64},
      ],
      'byDate': const [],
    });

    expect(tester.takeException(), isNull);
    expect(find.text('12.500.000 ₫'), findsOneWidget);
    expect(find.text(ReportStrings.collectionsTotal(3)), findsOneWidget);
    expect(find.text('Tiền mặt'), findsOneWidget);
    expect(find.text('4.500.000 ₫'), findsOneWidget);
    expect(find.text('Chuyển khoản'), findsNothing);
  });

  testWidgets('chưa thu gì thì nói rõ', (tester) async {
    await pump(tester, {'total': 0, 'payments': 0, 'byMethod': const [], 'byDate': const []});

    expect(find.text(ReportStrings.nothingCollectedToday), findsOneWidget);
  });
}
