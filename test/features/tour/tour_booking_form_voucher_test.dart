import 'package:booking_app_mobile/core/text/discover_strings.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_models.dart';
import 'package:booking_app_mobile/features/tour/presentation/bookings/tour_booking_form_screen.dart';
import 'package:booking_app_mobile/features/voucher/presentation/vouchers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> phone(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('đặt tour: người lớn / trẻ em tính giá riêng, có ô mã giảm giá', (tester) async {
    final tour = TourModel.fromJson({
      'id': 2,
      'name': 'Food tour phố cổ buổi tối',
      'price': 450000,
      'childPrice': 250000,
      'hotelId': 6,
      'available': true,
    });
    await phone(tester, TourBookingFormScreen(tour: tour, hotelName: 'Hoàn Kiếm Palace'));

    expect(tester.takeException(), isNull);
    expect(find.text(DiscoverStrings.adults), findsOneWidget);
    expect(find.text(DiscoverStrings.children), findsOneWidget);
    expect(find.text(DiscoverStrings.voucherApply), findsOneWidget);
    // 2 người lớn mặc định
    expect(find.text(DiscoverStrings.adultPart(2)), findsOneWidget);
    expect(find.text('900.000 ₫'), findsWidgets);

    // thêm một trẻ em: dòng giá trẻ em hiện ra
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text(DiscoverStrings.childPart(1)), findsOneWidget);
    expect(find.text('250.000 ₫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form mã giảm giá vừa khổ điện thoại', (tester) async {
    await phone(tester, const VoucherFormScreen(hotelChainId: 10));

    expect(tester.takeException(), isNull);
    expect(find.text('Mã'), findsOneWidget);
  });
}
