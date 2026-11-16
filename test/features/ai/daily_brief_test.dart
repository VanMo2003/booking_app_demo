import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_daily_brief_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _briefJson() => {
      'hotelId': 6,
      'date': '2026-11-16',
      'headline': 'Hôm nay có hai đơn treo và một tour sáng mai cần nhắc khách.',
      'signals': [
        {
          'key': 'pending_bookings',
          'label': 'Đơn phòng chờ xác nhận',
          'value': '2 đơn',
          'detail': '1 đơn đã chờ quá 24 giờ.',
          'level': 'URGENT',
        },
        {
          'key': 'tours_tomorrow',
          'label': 'Tour khởi hành ngày mai',
          'value': '1 đơn',
          'detail': '3 khách, nên nhắc khách từ hôm nay.',
          'level': 'WATCH',
        },
        {
          'key': 'low_reviews',
          'label': 'Đánh giá 2 sao trở xuống trong 7 ngày',
          'value': '0 đánh giá',
          'level': 'QUIET',
        },
      ],
      'tasks': [
        {
          'title': 'Gọi lại đơn đang treo',
          'priority': 'HIGH',
          'why': 'Khách chờ quá một ngày thường tự huỷ.',
          'how': 'Mở danh sách đơn chờ và xác nhận từng đơn.',
          'signalKey': 'pending_bookings',
        },
      ],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  int? asked;

  @override
  Future<DailyBrief> dailyBrief(int hotelId) async {
    asked = hotelId;
    return AiModels.dailyBrief(_briefJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc dòng số liệu, mức độ và việc nên làm', () {
    final brief = AiModels.dailyBrief(_briefJson());

    expect(brief.date, DateTime(2026, 11, 16));
    expect(brief.signals, hasLength(3));
    expect(brief.urgentCount, 1);
    // Dòng cần xử lý xếp gấp trước, dòng yên tĩnh tách sang danh sách riêng.
    expect(brief.live.map((signal) => signal.key), ['pending_bookings', 'tours_tomorrow']);
    expect(brief.calm.single.key, 'low_reviews');
    expect(brief.tasks.single.priority, AuditPriority.high);
    expect(brief.tasks.single.signalKey, 'pending_bookings');
  });

  test('mức độ lạ coi như không có việc gì', () {
    expect(BriefLevel.parse('URGENT'), BriefLevel.urgent);
    expect(BriefLevel.parse('gấp'), BriefLevel.quiet);
    expect(BriefLevel.parse(null), BriefLevel.quiet);
    expect(BriefLevel.urgent.needsWork, isTrue);
    expect(BriefLevel.quiet.needsWork, isFalse);
  });

  testWidgets('màn bản tin: việc nên làm, dòng cần xử lý và dòng đã kiểm tra', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiDailyBriefCubit>(() => AiDailyBriefCubit(GetDailyBrief(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiDailyBriefScreen(hotelId: 6, subtitle: 'Hoàn Kiếm Palace')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, 6);
    expect(find.text(AiStrings.briefUrgentCount(1)), findsOneWidget);
    expect(find.textContaining('hai đơn treo'), findsOneWidget);
    expect(find.text('Gọi lại đơn đang treo'), findsOneWidget);
    expect(find.text('Đơn phòng chờ xác nhận'), findsOneWidget);
    expect(find.text('1 đơn đã chờ quá 24 giờ.'), findsOneWidget);
    expect(find.text(AiStrings.briefUrgent), findsOneWidget);
    expect(find.text(AiStrings.briefWatch), findsOneWidget);
    // Dòng không có việc gì vẫn hiện, nhưng ở mục riêng phía dưới.
    expect(find.text('Đánh giá 2 sao trở xuống trong 7 ngày'), findsOneWidget);
    expect(find.text(AiStrings.briefAllQuiet), findsNothing);
  });
}
