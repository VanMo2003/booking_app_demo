import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/review_digest_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _digestJson({bool available = true}) => {
      'hotelId': 6,
      'available': available,
      if (available) 'summary': 'Khách thích vị trí trung tâm và phòng sạch. Một số thấy phố ồn vào cuối tuần.',
      'pros': available ? ['Vị trí ngay phố cổ', 'Phòng sạch, thơm'] : <String>[],
      'cons': available ? ['Tiếng ồn từ phố đi bộ'] : <String>[],
      'reviewCount': available ? 12 : 2,
      'averageRating': available ? 4.3 : 5,
      'ratingCounts': available ? [0, 1, 1, 4, 6] : [0, 0, 0, 0, 2],
      if (available) 'generatedAt': '2026-11-16T10:00:00Z',
    };

class _FakeAi implements AiRepository {
  _FakeAi({this.available = true, this.fails = false});

  final bool available;
  final bool fails;

  @override
  Future<bool> enabled() async => true;

  @override
  Future<ReviewDigest> reviewDigest(int hotelId) async {
    if (fails) throw Exception('mạng lỗi');
    return AiModels.reviewDigest(_digestJson(available: available));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, _FakeAi ai, {bool aiOn = true}) async {
  tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final availability = AiAvailability(ai);
  availability.enabled.value = aiOn;
  getIt
    ..registerSingleton<AiAvailability>(availability)
    ..registerFactory<GetReviewDigest>(() => GetReviewDigest(ai));
  addTearDown(getIt.reset);

  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ReviewDigestCard(hotelId: 6))));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc tóm tắt, điểm cộng, điểm trừ và phổ sao', () {
    final digest = AiModels.reviewDigest(_digestJson());

    expect(digest.available, isTrue);
    expect(digest.summary, contains('phòng sạch'));
    expect(digest.pros, hasLength(2));
    expect(digest.cons, ['Tiếng ồn từ phố đi bộ']);
    expect(digest.reviewCount, 12);
    expect(digest.averageRating, 4.3);
    expect(digest.ratingCounts, [0, 1, 1, 4, 6]);
    expect(digest.busiestRating, 6);
  });

  testWidgets('thẻ hiện tóm tắt và phổ sao', (tester) async {
    await _pump(tester, _FakeAi());

    expect(tester.takeException(), isNull);
    expect(find.text(AiStrings.digestTitle), findsOneWidget);
    expect(find.text(AiStrings.digestFrom(12)), findsOneWidget);
    expect(find.text('Vị trí ngay phố cổ'), findsOneWidget);
    expect(find.text('Tiếng ồn từ phố đi bộ'), findsOneWidget);
    expect(find.text(AiStrings.digestStars(5)), findsOneWidget);
  });

  testWidgets('chưa đủ đánh giá: thẻ ẩn hẳn', (tester) async {
    await _pump(tester, _FakeAi(available: false));

    expect(find.text(AiStrings.digestTitle), findsNothing);
  });

  testWidgets('máy chủ chưa bật AI hoặc gọi lỗi: thẻ ẩn hẳn, không làm vỡ trang', (tester) async {
    await _pump(tester, _FakeAi(), aiOn: false);
    expect(find.text(AiStrings.digestTitle), findsNothing);
    expect(tester.takeException(), isNull);

    await getIt.reset();
    await _pump(tester, _FakeAi(fails: true));
    expect(find.text(AiStrings.digestTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
