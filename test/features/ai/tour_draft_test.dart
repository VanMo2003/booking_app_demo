import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/core/text/tour_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/room/domain/entities/room.dart';
import 'package:booking_app_mobile/features/room/domain/repositories/room_repository.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/room_usecases.dart';
import 'package:booking_app_mobile/features/tour/domain/entities/travel_theme.dart';
import 'package:booking_app_mobile/features/tour/presentation/tour_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _draftJson() => {
      'description': 'Dạo phố cổ Hà Nội buổi tối cùng hướng dẫn viên bản địa.',
      'includes': 'Hướng dẫn viên, 8 món đặc sản, nước uống',
      'cancellationPolicy': 'Huỷ miễn phí trước giờ khởi hành 24 giờ.',
      'itinerary': [
        {'time': '18:00', 'title': 'Khởi hành từ khách sạn', 'description': 'Tập trung ở sảnh.'},
        {'time': '18:30', 'title': 'Bún chả và nem cua bể'},
      ],
    };

class _FakeAi implements AiRepository {
  Map<String, dynamic>? sent;

  @override
  Future<TourDraft> draftTour(Map<String, dynamic> body) async {
    sent = body;
    return AiModels.tourDraft(_draftJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _NoRooms implements RoomRepository {
  @override
  Future<List<Room>> getRooms(int hotelId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc nội dung nháp và lịch trình', () {
    final draft = AiModels.tourDraft(_draftJson());

    expect(draft.isEmpty, isFalse);
    expect(draft.description, contains('phố cổ'));
    expect(draft.includes, contains('8 món đặc sản'));
    expect(draft.cancellationPolicy, isNotNull);
    expect(draft.itinerary, hasLength(2));
    expect(draft.itinerary.first.time, '18:00');
    expect(draft.itinerary.last.description, isNull);
  });

  test('nháp rỗng được nhận ra', () {
    expect(const TourDraft().isEmpty, isTrue);
    expect(AiModels.tourDraft({'description': ''}).isEmpty, isTrue);
  });

  test('chỉ gửi những ô đã nhập', () async {
    final ai = _FakeAi();

    await DraftTourWithAi(ai)(
      hotelId: 6,
      name: '  Food tour phố cổ  ',
      destination: 'Phố cổ Hà Nội',
      duration: '   ',
      themes: [TravelTheme.food],
    );

    expect(ai.sent, {
      'hotelId': 6,
      'name': 'Food tour phố cổ',
      'destination': 'Phố cổ Hà Nội',
      'themes': ['FOOD'],
    });
  });

  testWidgets('biểu mẫu tour: bấm AI soạn nội dung thì các ô được điền', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    final availability = AiAvailability(ai);
    availability.enabled.value = true;
    getIt
      ..registerSingleton<AiAvailability>(availability)
      ..registerFactory<DraftTourWithAi>(() => DraftTourWithAi(ai))
      ..registerFactory<GetBranchRooms>(() => GetBranchRooms(_NoRooms()));
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: TourFormScreen(hotelId: 6)));
    await tester.pumpAndSettle();

    // Chưa có tên tour: AI chưa chạy.
    await tester.tap(find.text(AiStrings.draftTour));
    await tester.pumpAndSettle();
    expect(find.text(AiStrings.draftTourNeedsName), findsOneWidget);
    expect(ai.sent, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, TourStrings.name).first, 'Food tour phố cổ');
    await tester.tap(find.text(AiStrings.draftTour));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.sent!['name'], 'Food tour phố cổ');
    expect(find.text('Dạo phố cổ Hà Nội buổi tối cùng hướng dẫn viên bản địa.'), findsOneWidget);
    expect(find.text('Hướng dẫn viên, 8 món đặc sản, nước uống'), findsOneWidget);
    expect(find.text('Khởi hành từ khách sạn'), findsOneWidget);
    expect(find.text('Huỷ miễn phí trước giờ khởi hành 24 giờ.'), findsOneWidget);
  });
}
