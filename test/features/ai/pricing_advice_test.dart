import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/core/utils/formatters.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _adviceJson() => {
      'hotelId': 6,
      'from': '2026-10-18',
      'to': '2026-11-16',
      'outlookDays': 30,
      'summary': 'Deluxe gần kín, Standard còn trống nhiều vào giữa tuần.',
      'items': [
        {
          'roomTypeId': 1,
          'roomTypeName': 'Deluxe',
          'action': 'RAISE',
          'percent': 8,
          'reason': 'Lấp phòng 82,0% và ADR sát giá niêm yết.',
          'listPrice': 900000,
          'adr': 870000,
          'occupancyRate': 82,
          'rooms': 5,
          'suggestedPrice': 972000,
        },
        {
          'roomTypeId': 2,
          'roomTypeName': 'Standard',
          'action': 'HOLD',
          'listPrice': 600000,
          'adr': 450000,
          'occupancyRate': 31,
          'rooms': 8,
        },
      ],
      'risks': ['Tăng giá có thể làm giảm lượt đặt cuối tuần.'],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  int? asked;

  @override
  Future<PricingAdvice> pricingAdvice(int hotelId) async {
    asked = hotelId;
    return AiModels.pricingAdvice(_adviceJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc gợi ý theo loại phòng', () {
    final advice = AiModels.pricingAdvice(_adviceJson());

    expect(advice.hotelId, 6);
    expect(advice.from, DateTime(2026, 10, 18));
    expect(advice.outlookDays, 30);
    expect(advice.items, hasLength(2));

    final deluxe = advice.items.first;
    expect(deluxe.action, PricingAction.raise);
    expect(deluxe.percent, 8);
    expect(deluxe.suggestedPrice, 972000);

    final standard = advice.items.last;
    expect(standard.action, PricingAction.hold);
    expect(standard.percent, isNull);
    expect(standard.suggestedPrice, isNull);
    expect(advice.risks, hasLength(1));
  });

  test('hướng xử lý lạ được coi là giữ nguyên', () {
    expect(PricingAction.parse('LOWER'), PricingAction.lower);
    expect(PricingAction.parse('tăng'), PricingAction.hold);
    expect(PricingAction.parse(null), PricingAction.hold);
  });

  testWidgets('màn tư vấn giá: giá cũ, giá đề xuất, lý do và điều cần cân nhắc', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiPricingCubit>(() => AiPricingCubit(GetPricingAdvice(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiPricingScreen(hotelId: 6, subtitle: 'Hoàn Kiếm Palace')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, 6);
    expect(find.text('Deluxe'), findsOneWidget);
    expect(find.text('${AiStrings.pricingRaise} 8%'), findsOneWidget);
    expect(find.text('900.000 ₫'), findsOneWidget);
    expect(find.text('972.000 ₫'), findsOneWidget);
    expect(find.text(AiStrings.pricingHold), findsOneWidget);
    expect(find.text(AiStrings.pricingOccupancy(Fmt.decimal(82))), findsOneWidget);
    expect(find.textContaining('giảm lượt đặt cuối tuần'), findsOneWidget);
  });
}
