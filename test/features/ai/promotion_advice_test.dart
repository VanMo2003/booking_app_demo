import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_promotion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _adviceJson() => {
      'hotelChainId': 3,
      'from': '2026-10-20',
      'to': '2026-11-18',
      'occupancyRate': 61.4,
      'adr': 843000,
      'outlookOccupancy': 22.4,
      'runningVouchers': ['GIAMHE10 - Giảm hè (toàn chuỗi, đến 2026-11-23)'],
      'campaigns': [
        {
          'title': 'Giảm 10% đêm giữa tuần',
          'scope': 'CHAIN',
          'discountPercent': 10,
          'minOrderAmount': 840000,
          'startsAt': '2026-11-18',
          'endsAt': '2026-12-01',
          'why': 'Thứ ba chỉ lấp 31% phòng.',
          'tours': ['Food tour phố cổ'],
        },
        {
          'title': 'Giảm 15% cho Ba Đình Riverside',
          'scope': 'BRANCH',
          'hotelId': 7,
          'hotelName': 'Ba Đình Riverside',
          'discountPercent': 15,
          'startsAt': '2026-11-18',
          'endsAt': '2026-11-24',
          'why': 'Cơ sở này hụt 12,5% so kỳ trước.',
          'tours': <String>[],
        },
      ],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  int? asked;

  @override
  Future<PromotionAdvice> promotionAdvice(int hotelChainId) async {
    asked = hotelChainId;
    return AiModels.promotionAdvice(_adviceJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc chương trình, phạm vi và mã đang chạy', () {
    final advice = AiModels.promotionAdvice(_adviceJson());

    expect(advice.campaigns, hasLength(2));
    expect(advice.campaigns.first.chainWide, isTrue);
    expect(advice.campaigns.first.hotelName, isNull);
    expect(advice.campaigns.first.endsAt, DateTime(2026, 12, 1));
    expect(advice.campaigns.first.tours, ['Food tour phố cổ']);
    // Chương trình cho một cơ sở mang theo mã và tên cơ sở đó.
    expect(advice.campaigns.last.chainWide, isFalse);
    expect(advice.campaigns.last.hotelId, 7);
    expect(advice.runningVouchers, hasLength(1));
    expect(advice.outlookOccupancy, 22.4);
  });

  test('thiếu scope coi như cả chuỗi', () {
    final advice = AiModels.promotionAdvice({
      'hotelChainId': 3,
      'campaigns': [
        {'title': 'Giảm 10%', 'discountPercent': 10, 'why': 'Trống nhiều.'},
      ],
    });

    expect(advice.campaigns.single.chainWide, isTrue);
    expect(advice.campaigns.single.minOrderAmount, isNull);
    expect(advice.campaigns.single.startsAt, isNull);
  });

  testWidgets('màn gợi ý: số liệu kỳ, chương trình và mã đang chạy', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiPromotionCubit>(() => AiPromotionCubit(GetPromotionAdvice(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiPromotionScreen(hotelChainId: 3, subtitle: 'Chuỗi Mơ Mộng')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, 3);
    expect(find.text('Giảm 10% đêm giữa tuần'), findsOneWidget);
    expect(find.text('-10%'), findsOneWidget);
    expect(find.text('-15%'), findsOneWidget);
    expect(find.text(AiStrings.promoChainWide), findsOneWidget);
    expect(find.text('Ba Đình Riverside'), findsOneWidget);
    expect(find.text('Thứ ba chỉ lấp 31% phòng.'), findsOneWidget);
    expect(find.textContaining('GIAMHE10'), findsOneWidget);
    // Mỗi chương trình có lối sang trang mã giảm giá, vì màn này không tạo mã.
    expect(find.text(AiStrings.promoCreate), findsNWidgets(2));
  });
}
