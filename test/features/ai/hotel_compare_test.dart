import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_hotel_compare_screen.dart';
import 'package:booking_app_mobile/features/ai/presentation/compare_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _compareJson() => {
      'items': [
        {
          'hotelId': 6,
          'name': 'Hoàn Kiếm Palace',
          'category': 'Standard',
          'address': '12 Hàng Bạc, Hà Nội',
          'priceFrom': 800000,
          'priceTo': 2500000,
          'maxCapacity': 4,
          'rooms': 8,
          'amenities': 5,
          'services': 3,
          'tours': 2,
          'reviews': 12,
          'averageRating': 4.3,
          'fitFor': 'Phù hợp gia đình có trẻ nhỏ.',
        },
        {
          'hotelId': 7,
          'name': 'Ba Đình Riverside',
          'address': '5 Đội Cấn, Hà Nội',
          'maxCapacity': 2,
          'rooms': 4,
          'amenities': 2,
          'services': 1,
          'tours': 0,
          'reviews': 0,
          'averageRating': 0,
        },
      ],
      'differences': ['Hoàn Kiếm Palace có phòng 4 khách, Ba Đình Riverside tối đa 2 khách.'],
      'verdict': 'Đi cùng gia đình thì chọn Hoàn Kiếm Palace.',
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  List<int>? asked;

  @override
  Future<HotelCompare> compareHotels(List<int> hotelIds) async {
    asked = hotelIds;
    return AiModels.hotelCompare(_compareJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc bảng so sánh, cơ sở thiếu giá và thiếu đánh giá', () {
    final compare = AiModels.hotelCompare(_compareJson());

    expect(compare.items, hasLength(2));
    expect(compare.items.first.priceFrom, 800000);
    expect(compare.items.first.fitFor, startsWith('Phù hợp gia đình'));
    // Cơ sở chưa có phòng nào có giá và chưa có đánh giá đọc ra null/0, không phải một con số bịa.
    expect(compare.items.last.priceFrom, isNull);
    expect(compare.items.last.reviews, 0);
    expect(compare.items.last.fitFor, isNull);
    expect(compare.verdict, startsWith('Đi cùng gia đình'));
  });

  testWidgets('màn so sánh: kết luận, khác biệt và bảng số liệu', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiHotelCompareCubit>(() => AiHotelCompareCubit(CompareHotelsWithAi(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AiHotelCompareScreen(hotelIds: [6, 7])));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, [6, 7]);
    expect(find.text('Đi cùng gia đình thì chọn Hoàn Kiếm Palace.'), findsOneWidget);
    expect(find.text('Hoàn Kiếm Palace'), findsOneWidget);
    expect(find.text('Ba Đình Riverside'), findsOneWidget);
    expect(find.text(AiStrings.compareNoPrice), findsOneWidget);
    expect(find.text(AiStrings.compareNoReview), findsOneWidget);
    expect(find.text(AiStrings.compareRooms(8, 4)), findsOneWidget);
  });

  testWidgets('bảng chọn: cần 2 cơ sở mới so sánh được, tối đa 4, giữ thứ tự bấm', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    List<int>? picked;
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  picked = await showComparePicker(context, [
                    for (var id = 1; id <= 5; id++) ComparableHotel(id: id, name: 'Cơ sở $id'),
                  ]);
                  closed = true;
                },
                child: const Text('mở'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();

    // Chưa chọn gì thì nút so sánh bị khoá: bấm vào không đóng bảng.
    await tester.tap(find.text(AiStrings.compareGo));
    await tester.pumpAndSettle();
    expect(closed, isFalse);

    for (var id = 5; id >= 1; id--) {
      await tester.tap(find.text('Cơ sở $id'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text(AiStrings.compareGo));
    await tester.pumpAndSettle();

    // Đủ 4 cơ sở thì ô thứ năm bị khoá, và thứ tự khách bấm được giữ nguyên.
    expect(picked, [5, 4, 3, 2]);
  });
}
