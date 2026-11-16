import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_report_ask_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _answerJson() => {
      'question': 'Doanh thu tháng này so với tháng trước thế nào?',
      'from': '2026-11-01',
      'to': '2026-11-16',
      'scope': 'chain',
      'answer': 'Doanh thu kỳ này đạt 120.000.000 ₫, tăng 20,0% so với kỳ trước. Phần tăng đến từ tour.',
      'highlights': ['Doanh thu 120.000.000 ₫, tăng 20,0%', 'Lấp phòng 42,5%'],
      'suggestions': ['Mở thêm chuyến cho tour du thuyền vào cuối tuần'],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  Map<String, dynamic>? sent;

  @override
  Future<AiReportAnswer> askReports(Map<String, dynamic> body) async {
    sent = body;
    return AiModels.reportAnswer(_answerJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc câu trả lời, kỳ số liệu, số đáng chú ý và gợi ý', () {
    final answer = AiModels.reportAnswer(_answerJson());

    expect(answer.scope, 'chain');
    expect(answer.from, DateTime(2026, 11, 1));
    expect(answer.to, DateTime(2026, 11, 16));
    expect(answer.answer, contains('120.000.000 ₫'));
    expect(answer.highlights, hasLength(2));
    expect(answer.suggestions, hasLength(1));
  });

  test('chỉ gửi một phạm vi: cơ sở hoặc chuỗi', () async {
    final ai = _FakeAi();

    await AskReportsWithAi(ai)('  Doanh thu tháng này?  ', hotelChainId: 10);
    expect(ai.sent, {'query': 'Doanh thu tháng này?', 'hotelChainId': 10});

    await AskReportsWithAi(ai)('Tour nào tốt nhất?', hotelId: 6);
    expect(ai.sent, {'query': 'Tour nào tốt nhất?', 'hotelId': 6});
  });

  testWidgets('màn hỏi số liệu: gõ câu hỏi, hiện câu trả lời kèm kỳ số liệu', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiReportAskCubit>(() => AiReportAskCubit(AskReportsWithAi(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AiReportAskScreen(hotelChainId: 10, subtitle: 'Hotel Number 1')));
    await tester.pumpAndSettle();

    expect(find.text(AiStrings.askExamples.first), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Doanh thu tháng này so với tháng trước thế nào?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.sent!['hotelChainId'], 10);
    expect(find.textContaining('tăng 20,0%'), findsWidgets);
    expect(find.text('${AiStrings.askPeriod}: 01/11/2026 – 16/11/2026'), findsOneWidget);
    expect(find.text(AiStrings.askHighlights.toUpperCase()), findsOneWidget);
    expect(find.text('Mở thêm chuyến cho tour du thuyền vào cuối tuần'), findsOneWidget);
  });
}
