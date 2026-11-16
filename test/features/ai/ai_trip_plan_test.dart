import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_trip_plan_screen.dart';
import 'package:booking_app_mobile/features/tour/domain/entities/travel_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _planJson({bool empty = false}) => {
      'query': 'Hạ Long 3 ngày 2 đêm cho 2 người lớn 1 trẻ em, khoảng 6 triệu, thích biển',
      'summary': 'Hạ Long 3 ngày 2 đêm nghiêng về biển và ẩm thực',
      'destination': 'Hạ Long',
      'startDate': '2026-12-05',
      'nights': 2,
      'adults': 2,
      'children': 1,
      'themes': ['BEACH', 'FOOD'],
      'budget': 6000000,
      if (!empty)
        'stay': {
          'hotelId': 6,
          'hotelName': 'Hạ Long Bay Hotel',
          'address': '12 Bãi Cháy, Hạ Long',
          'category': 'Grand',
          'rating': 4.5,
          'roomId': 90,
          'roomNumber': '101',
          'roomType': 'Deluxe',
          'capacity': 3,
          'pricePerNight': 900000,
          'checkin': '2026-12-05',
          'checkout': '2026-12-07',
        },
      'days': empty
          ? <dynamic>[]
          : [
              {
                'index': 1,
                'date': '2026-12-05',
                'title': 'Nhận phòng và dạo Bãi Cháy',
                'steps': [
                  {'time': '14:00', 'title': 'Nhận phòng', 'detail': 'Gửi hành lý rồi nghỉ ngơi.'},
                ],
              },
              {
                'index': 2,
                'date': '2026-12-06',
                'title': 'Du thuyền vịnh',
                'steps': [
                  {'time': '08:00', 'title': 'Du thuyền vịnh Hạ Long', 'tourId': 7},
                ],
              },
            ],
      'tours': empty
          ? <dynamic>[]
          : [
              {
                'id': 7,
                'name': 'Du thuyền vịnh Hạ Long',
                'price': 500000,
                'salePrice': 500000,
                'hotelId': 6,
                'hotelName': 'Hạ Long Bay Hotel',
                'available': true,
              },
            ],
      'voucher': empty
          ? null
          : {
              'id': 2,
              'code': 'HALONG200',
              'title': 'Giảm 200.000 ₫ cho đơn tour',
              'discountType': 'AMOUNT',
              'value': 200000,
              'startsAt': '2026-11-01',
              'endsAt': '2027-03-31',
            },
      'cost': empty
          ? {'rooms': 0, 'tours': 0, 'total': 0, 'perPerson': 0}
          : {
              'rooms': 1800000,
              'tours': 1300000,
              'voucherDiscount': 200000,
              'total': 2900000,
              'perPerson': 966667,
              'leftOver': 3100000,
            },
      'notes': empty ? ['Chưa có cơ sở nào còn phòng trống ở Hạ Long cho ngày này.'] : <String>[],
    };

class _FakeAi implements AiRepository {
  _FakeAi({this.empty = false});

  final bool empty;

  @override
  Future<AiTripPlan> planTrip(String query) async => AiModels.tripPlan(_planJson(empty: empty));

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, {bool empty = false}) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  getIt.registerFactory<AiTripPlanCubit>(() => AiTripPlanCubit(PlanTripWithAi(_FakeAi(empty: empty))));
  addTearDown(getIt.reset);

  await tester.pumpWidget(const MaterialApp(home: AiTripPlanScreen()));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Hạ Long 3 ngày 2 đêm');
  await tester.tap(find.text(AiStrings.tripAction));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc kế hoạch: nơi ở, lịch trình từng ngày, tour, voucher và chi phí', () {
    final plan = AiModels.tripPlan(_planJson());

    expect(plan.destination, 'Hạ Long');
    expect(plan.nights, 2);
    expect(plan.guests, 3);
    expect(plan.themes, [TravelTheme.beach, TravelTheme.food]);
    expect(plan.stay!.roomNumber, '101');
    expect(plan.stay!.checkout, DateTime(2026, 12, 7));
    expect(plan.days, hasLength(2));
    expect(plan.days.last.steps.single.tourId, 7);
    expect(plan.tours.single.name, 'Du thuyền vịnh Hạ Long');
    expect(plan.voucher!.code, 'HALONG200');
    expect(plan.cost.total, 2900000);
    expect(plan.cost.leftOver, 3100000);
    expect(plan.cost.overBudget, isFalse);
    expect(plan.isEmpty, isFalse);
  });

  test('vượt ngân sách được nhận ra', () {
    final json = _planJson();
    (json['cost'] as Map<String, dynamic>)['leftOver'] = -500000;

    expect(AiModels.tripPlan(json).cost.overBudget, isTrue);
  });

  test('thẻ mô tả chuyến đi', () {
    final chips = AiTripChips.of(AiModels.tripPlan(_planJson()));

    expect(chips, contains('Hạ Long'));
    expect(chips, contains(AiStrings.tripNights(2)));
    expect(chips, contains(AiStrings.tourGuests(2, 1)));
    expect(chips, contains('Biển'));
    expect(chips, contains(AiStrings.tripBudget('6.000.000 ₫')));
  });

  testWidgets('màn kế hoạch: nơi ở, từng ngày, tour và tổng tiền', (tester) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Hạ Long Bay Hotel'), findsWidgets);
    expect(find.text(AiStrings.tripRoom('101', 'Deluxe')), findsOneWidget);
    expect(find.text('${AiStrings.tripDay} 1'), findsOneWidget);
    expect(find.text('Nhận phòng'), findsOneWidget);
    expect(find.text('Du thuyền vịnh Hạ Long'), findsWidgets);
    expect(find.text('2.900.000 ₫'), findsOneWidget);
    expect(find.text('-200.000 ₫'), findsOneWidget);
    expect(find.text(AiStrings.tripBookStay), findsOneWidget);
  });

  testWidgets('không còn phòng: chỉ hiện điều AI hiểu và ghi chú', (tester) async {
    await _pump(tester, empty: true);

    expect(tester.takeException(), isNull);
    expect(find.text(AiStrings.tripNothing), findsOneWidget);
    expect(find.textContaining('Chưa có cơ sở nào còn phòng'), findsOneWidget);
    expect(find.text(AiStrings.tripBookStay), findsNothing);
  });
}
