import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_tour_search_screen.dart';
import 'package:booking_app_mobile/features/tour/domain/entities/travel_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _responseJson() => {
      'query': 'tour biển Hạ Long 2 ngày cho 2 người lớn 1 trẻ em dưới 3 triệu',
      'summary': 'Tour biển Hạ Long · 2 người lớn 1 trẻ em · dưới 3.000.000 ₫',
      'filters': {
        'destinations': ['Hạ Long', 'Quảng Ninh'],
        'themes': ['BEACH', 'UNKNOWN'],
        'maxPrice': 3000000,
        'adults': 2,
        'children': 1,
        'tourDate': '2026-12-05',
        'nights': 1,
        'withRooms': true,
        'keywords': ['du thuyền'],
      },
      'results': [
        {
          'id': 7,
          'name': 'Du thuyền vịnh Hạ Long 2 ngày 1 đêm',
          'price': 2450000,
          'childPrice': 1800000,
          'hotelId': 6,
          'hotelName': 'Hạ Long Bay Hotel',
          'destination': 'Hạ Long, Quảng Ninh',
          'themes': ['BEACH', 'NATURE'],
          'available': true,
          'stayNights': 1,
        },
      ],
      'notes': ['Có 1 tour phù hợp nhưng đã kín chỗ ngày 2026-12-05.'],
    };

class _FakeAi implements AiRepository {
  @override
  Future<AiTourSearchResult> searchTours(String query) async => AiModels.tourSearchResult(_responseJson());

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc bộ lọc, tour và ghi chú từ máy chủ', () {
    final result = AiModels.tourSearchResult(_responseJson());

    expect(result.summary, contains('Hạ Long'));
    expect(result.filters.destinations, ['Hạ Long', 'Quảng Ninh']);
    // Chủ đề lạ bị bỏ qua chứ không làm vỡ màn hình.
    expect(result.filters.themes, [TravelTheme.beach]);
    expect(result.filters.maxPrice, 3000000);
    expect(result.filters.adults, 2);
    expect(result.filters.children, 1);
    expect(result.filters.guests, 3);
    expect(result.filters.tourDate, DateTime(2026, 12, 5));
    expect(result.filters.withRooms, isTrue);
    expect(result.results.single.name, 'Du thuyền vịnh Hạ Long 2 ngày 1 đêm');
    expect(result.results.single.childPayPrice, 1800000);
    expect(result.notes, hasLength(1));
  });

  test('thẻ bộ lọc hiện đúng điều AI hiểu', () {
    final chips = AiTourSearchChips.of(AiModels.tourSearchResult(_responseJson()).filters);

    expect(chips, contains('Hạ Long'));
    expect(chips, contains('Biển'));
    expect(chips, contains(AiStrings.tourGuests(2, 1)));
    expect(chips, contains(AiStrings.priceUnder('3.000.000 ₫')));
    expect(chips, contains(AiStrings.tourWithRooms));
    expect(chips, contains('du thuyền'));
  });

  testWidgets('màn tìm tour bằng AI: gõ câu, hiện tour và ghi chú', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    getIt.registerFactory<AiTourSearchCubit>(() => AiTourSearchCubit(SearchToursWithAi(_FakeAi())));
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AiTourSearchScreen()));
    await tester.pumpAndSettle();

    // Chưa tìm gì: chỉ có câu mẫu.
    expect(find.text(AiStrings.tourExamples.first), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tour biển Hạ Long 2 ngày');
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AiStrings.tourResultsCount(1)), findsOneWidget);
    expect(find.text('Du thuyền vịnh Hạ Long 2 ngày 1 đêm'), findsOneWidget);
    expect(find.textContaining('kín chỗ'), findsOneWidget);
  });
}
