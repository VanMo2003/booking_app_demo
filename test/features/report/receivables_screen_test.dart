import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:booking_app_mobile/features/booking/domain/usecases/booking_usecases.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/domain/entities/report_entities.dart';
import 'package:booking_app_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:booking_app_mobile/features/report/presentation/receivables/receivables_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeReports implements ReportRepository {
  _FakeReports(this.rows);

  final List<Receivable> rows;

  @override
  Future<List<Receivable>> receivables(ReportScope scope) async => rows;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _NoBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Receivable _row(int id, String guest, num amount, int days) => ReportModel.receivable({
      'bookingId': id,
      'hotelId': 6,
      'hotelName': 'Hoàn Kiếm',
      'customerName': guest,
      'phoneNumber': '0901234567',
      'checkoutDate': '2026-10-12',
      'totalAmount': amount,
      'paymentMethod': 'CASH',
      'daysOverdue': days,
    });

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => getIt.reset());

  Future<void> pump(WidgetTester tester, List<Receivable> rows) async {
    getIt.registerFactory<ReceivablesCubit>(
      () => ReceivablesCubit(_FakeReports(rows), ChangeBookingStatus(_NoBookings())),
    );
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ReceivablesScreen(hotelId: 6)));
    await tester.pumpAndSettle();
  }

  testWidgets('liệt kê đơn chưa thu: tổng tiền, khách, số ngày quá hạn', (tester) async {
    await pump(tester, [_row(21, 'Nguyễn An', 1200000, 16), _row(22, 'Trần Bình', 800000, 0)]);

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.receivablesTotal(2)), findsOneWidget);
    expect(find.text('2.000.000 ₫'), findsOneWidget);
    expect(find.text('Nguyễn An'), findsOneWidget);
    expect(find.text(ReportStrings.receivableDue('12/10/2026', 16)), findsOneWidget);
    expect(find.text(ReportStrings.receivableDue('12/10/2026', 0)), findsOneWidget);
  });

  testWidgets('không còn khoản nào: màn trống', (tester) async {
    await pump(tester, const []);

    expect(find.text(ReportStrings.receivablesEmpty), findsOneWidget);
  });
}
