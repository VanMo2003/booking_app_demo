import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_translation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _translationJson(String lang) => {
      'hotelId': 6,
      'lang': lang,
      'language': lang == 'en' ? 'English' : '한국어',
      'items': [
        {
          'key': 'hotel_description',
          'section': 'DESCRIPTION',
          'original': 'Khách sạn nằm trong phố cổ.',
          'translated': lang == 'en' ? 'A hotel in the Old Quarter.' : '구시가지에 있는 호텔입니다.',
        },
        {
          'key': 'amenity_1',
          'section': 'AMENITY',
          'original': 'Hồ bơi',
          'translated': lang == 'en' ? 'Swimming pool' : '수영장',
        },
        {
          // Mục này model bỏ qua: không có trường translated.
          'key': 'dish_4',
          'section': 'DISH',
          'original': 'Bún chả',
        },
      ],
      'notes': ['Còn 1 mục chưa dịch được, phần đó vẫn hiện bản gốc.'],
    };

class _FakeAi implements AiRepository {
  final List<String> askedLangs = [];

  @override
  Future<HotelTranslation> translateHotel(int hotelId, String lang) async {
    askedLangs.add(lang);
    return AiModels.hotelTranslation(_translationJson(lang));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('mục chưa dịch được thì text lùi về bản gốc', () {
    final translation = AiModels.hotelTranslation(_translationJson('en'));

    expect(translation.language, 'English');
    expect(translation.items, hasLength(3));
    expect(translation.items.first.text, 'A hotel in the Old Quarter.');
    expect(translation.items.first.untranslated, isFalse);
    // Không có bản dịch: text là bản gốc và mục được đánh dấu.
    expect(translation.items.last.untranslated, isTrue);
    expect(translation.items.last.text, 'Bún chả');
  });

  test('nhóm mục theo từng phần của trang', () {
    final translation = AiModels.hotelTranslation(_translationJson('en'));

    expect(translation.section('AMENITY').single.key, 'amenity_1');
    expect(translation.section('DISH').single.key, 'dish_4');
    expect(translation.section('TOUR'), isEmpty);
  });

  testWidgets('màn dịch: hiện bản dịch, đánh dấu mục còn bản gốc, đổi được ngôn ngữ', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiTranslationCubit>(() => AiTranslationCubit(TranslateHotelPage(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiTranslationScreen(hotelId: 6, subtitle: 'Hoàn Kiếm Palace')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.askedLangs, ['en']);
    expect(find.text('A hotel in the Old Quarter.'), findsOneWidget);
    expect(find.text('Swimming pool'), findsOneWidget);
    // Bản gốc hiện bên dưới bản dịch, và mục chưa dịch được bị đánh dấu.
    expect(find.text('Khách sạn nằm trong phố cổ.'), findsOneWidget);
    expect(find.text(AiStrings.translateOriginal), findsOneWidget);
    expect(find.text(AiStrings.translateDishes), findsOneWidget);

    await tester.tap(find.text('한국어'));
    await tester.pumpAndSettle();

    expect(ai.askedLangs, ['en', 'ko']);
    expect(find.text('구시가지에 있는 호텔입니다.'), findsOneWidget);
  });
}
