import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/target_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _progress({
  int? hotelId = 6,
  String? name = 'Hoàn Kiếm',
  num? target = 10000000,
  num revenue = 4000000,
  num projected = 9000000,
}) =>
    {
      'hotelId': hotelId,
      'hotelName': name,
      'month': '2026-10',
      'target': target,
      'revenue': revenue,
      'projectedRevenue': projected,
      'achievedRate': target == null ? null : revenue * 100 / target,
      'projectedRate': target == null ? null : projected * 100 / target,
      'daysElapsed': 20,
      'daysInMonth': 31,
    };

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Widget card) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: card))),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cơ sở có mục tiêu: đã đạt, dự kiến cả tháng và phần còn thiếu', (tester) async {
    var edits = 0;
    await pump(tester, TargetProgressCard(progress: ReportModel.target(_progress()), onEdit: () => edits++));

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.targetTitle('10/2026')), findsOneWidget);
    expect(find.text(ReportStrings.targetAchieved('4.000.000 ₫', '10.000.000 ₫')), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(
      find.text('${ReportStrings.targetProjected('9.000.000 ₫', '90%')} · ${ReportStrings.targetShortfall('1.000.000 ₫')}'),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.flag_outlined));
    expect(edits, 1);
  });

  testWidgets('chuỗi: tổng chuỗi và từng cơ sở, cơ sở chưa đặt mục tiêu chạm để đặt', (tester) async {
    final edited = <int?>[];
    final targets = ReportModel.chainTarget({
      'chain': _progress(hotelId: null, name: null),
      'branches': [_progress(), _progress(hotelId: 7, name: 'Đà Nẵng', target: null, revenue: 3000000)],
    });
    await pump(
      tester,
      TargetProgressCard(
        progress: targets.chain,
        branches: targets.branches,
        onEditBranch: (branch) => edited.add(branch.hotelId),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.chainTargetNote), findsOneWidget);
    expect(find.text(ReportStrings.noTargetShort), findsOneWidget);
    await tester.tap(find.text('Đà Nẵng'));
    expect(edited, [7]);
  });

  testWidgets('chưa đặt mục tiêu: nút đặt mục tiêu', (tester) async {
    var edits = 0;
    await pump(
      tester,
      TargetProgressCard(progress: ReportModel.target(_progress(target: null)), onEdit: () => edits++),
    );

    expect(find.text(ReportStrings.noTarget), findsOneWidget);
    await tester.tap(find.text(ReportStrings.setTarget));
    expect(edits, 1);
  });
}
