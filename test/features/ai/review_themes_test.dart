import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/core/utils/formatters.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_review_themes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _themesJson() => {
      'hotelChainId': 10,
      'from': '2026-08-19',
      'to': '2026-11-16',
      'reviewCount': 24,
      'summary': 'Khách khen vị trí và nhân viên, phàn nàn tiếng ồn ở cơ sở Hạ Long.',
      'themes': [
        {
          'topic': 'Vị trí',
          'sentiment': 'GOOD',
          'note': 'Gần phố cổ, đi bộ được nhiều chỗ.',
          'branches': ['Hoàn Kiếm Palace'],
        },
        {
          'topic': 'Tiếng ồn',
          'sentiment': 'BAD',
          'note': 'Phòng mặt đường ồn buổi tối.',
          'branches': ['Hạ Long Bay Hotel'],
        },
        {'topic': 'Bữa sáng', 'sentiment': 'không rõ', 'note': 'Người khen người không.'},
      ],
      'actions': ['Đổi cửa sổ cách âm cho phòng mặt đường'],
      'byBranch': [
        {'hotelId': 6, 'hotelName': 'Hoàn Kiếm Palace', 'reviews': 18, 'averageRating': 4.4},
        {'hotelId': 7, 'hotelName': 'Hạ Long Bay Hotel', 'reviews': 0},
      ],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  DateTime? from;
  DateTime? to;

  @override
  Future<ReviewThemes> reviewThemes(int hotelChainId, {required DateTime from, required DateTime to}) async {
    this.from = from;
    this.to = to;
    return AiModels.reviewThemes(_themesJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc chủ đề, cơ sở bị nhắc và điểm từng cơ sở', () {
    final themes = AiModels.reviewThemes(_themesJson());

    expect(themes.reviewCount, 24);
    expect(themes.themes, hasLength(3));
    expect(themes.themes.first.sentiment, ThemeSentiment.good);
    expect(themes.themes[1].sentiment, ThemeSentiment.bad);
    // Mức lạ coi như lẫn lộn.
    expect(themes.themes.last.sentiment, ThemeSentiment.mixed);
    expect(themes.themes.first.branches, ['Hoàn Kiếm Palace']);
    expect(themes.byBranch.last.averageRating, isNull);
    expect(themes.actions, hasLength(1));
  });

  testWidgets('màn phân tích: chủ đề, mức, cơ sở và điểm theo cơ sở', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiReviewThemesCubit>(() => AiReviewThemesCubit(GetReviewThemes(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiReviewThemesScreen(hotelChainId: 10, subtitle: 'Hotel Number 1')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Mặc định 90 ngày.
    expect(ai.to!.difference(ai.from!).inDays, 89);
    expect(find.text('Vị trí'), findsOneWidget);
    expect(find.text(AiStrings.themesGood), findsOneWidget);
    expect(find.text(AiStrings.themesBad), findsOneWidget);
    expect(find.text(AiStrings.themesMixed), findsOneWidget);
    expect(find.text('Hạ Long Bay Hotel'), findsWidgets);
    expect(find.text(AiStrings.themesBranchValue(18, Fmt.decimal(4.4))), findsOneWidget);
    expect(find.text(AiStrings.themesNoReview), findsOneWidget);

    // Đổi kỳ: gọi lại với khoảng 30 ngày.
    await tester.tap(find.text(AiStrings.themesWindow(30)));
    await tester.pumpAndSettle();
    expect(ai.to!.difference(ai.from!).inDays, 29);
  });
}
