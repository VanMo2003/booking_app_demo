import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/chat_summary_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _summaryJson({String urgency = 'HIGH', int messages = 14}) => {
      'conversationId': 12,
      'summary': 'Khách muốn nhận phòng muộn 22h và hỏi có thêm giường phụ không.',
      'openItems': ['Xác nhận nhận phòng muộn', 'Trả lời về giường phụ'],
      'nextSteps': ['Nhắn lại cho khách trong hôm nay'],
      'urgency': urgency,
      'waitingOnHotel': true,
      'needsStaff': true,
      'handoffReason': 'Khách cần xác nhận đặc biệt',
      'messageCount': messages,
    };

class _FakeAi implements AiRepository {
  _FakeAi({this.json});

  final Map<String, dynamic>? json;

  @override
  Future<ChatSummary> chatSummary(int conversationId) async => AiModels.chatSummary(json ?? _summaryJson());

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc tóm tắt, việc còn treo và mức gấp', () {
    final summary = AiModels.chatSummary(_summaryJson());

    expect(summary.conversationId, 12);
    expect(summary.urgency, ChatUrgency.high);
    expect(summary.openItems, hasLength(2));
    expect(summary.nextSteps, hasLength(1));
    expect(summary.waitingOnHotel, isTrue);
    expect(summary.needsStaff, isTrue);
    expect(summary.messageCount, 14);
    expect(summary.isEmpty, isFalse);
  });

  test('mức gấp lạ coi như bình thường, hội thoại rỗng được nhận ra', () {
    expect(ChatUrgency.parse('rất gấp'), ChatUrgency.normal);
    expect(ChatUrgency.parse(null), ChatUrgency.normal);
    expect(AiModels.chatSummary(_summaryJson(messages: 0)).isEmpty, isTrue);
  });

  testWidgets('bảng tóm tắt hiện mức gấp, việc treo và việc nên làm', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    getIt.registerFactory<GetChatSummary>(() => GetChatSummary(_FakeAi()));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showChatSummary(context, 12),
              child: const Text('mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AiStrings.summaryTitle), findsOneWidget);
    expect(find.text(AiStrings.summaryUrgency(ChatUrgency.high)), findsOneWidget);
    expect(find.text(AiStrings.summaryFrom(14)), findsOneWidget);
    expect(find.text(AiStrings.summaryWaiting), findsOneWidget);
    expect(find.text('Xác nhận nhận phòng muộn'), findsOneWidget);
    expect(find.text('Nhắn lại cho khách trong hôm nay'), findsOneWidget);
    expect(find.text(AiStrings.summaryNote), findsOneWidget);
  });

  testWidgets('hội thoại chưa có tin nhắn: bảng nói rõ', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    getIt.registerFactory<GetChatSummary>(
      () => GetChatSummary(_FakeAi(json: _summaryJson(messages: 0, urgency: 'LOW'))),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showChatSummary(context, 12),
              child: const Text('mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();

    expect(find.text(AiStrings.summaryEmpty), findsOneWidget);
    expect(find.text(AiStrings.summaryUrgency(ChatUrgency.low)), findsOneWidget);
  });
}
