import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_guest_assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _answerJson() => {
      'question': 'Đơn sắp tới của tôi thế nào?',
      'answer': 'Bạn có đơn phòng #26 ở Hoàn Kiếm Palace, nhận phòng 05/12 và còn chờ khách sạn xác nhận.',
      'suggestions': ['Xem lại đơn trong mục Đơn của tôi'],
      'links': [
        {'label': 'Xem đơn phòng #26', 'target': 'bookings/26'},
        {'label': 'Xem tour đã đặt', 'target': 'tours/7'},
      ],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  String? asked;

  @override
  Future<GuestAnswer> askAssistant(String query) async {
    asked = query;
    return AiModels.guestAnswer(_answerJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc câu trả lời, gợi ý và liên kết', () {
    final answer = AiModels.guestAnswer(_answerJson());

    expect(answer.answer, contains('#26'));
    expect(answer.suggestions, hasLength(1));
    expect(answer.links, hasLength(2));
    expect(answer.links.first.target, 'bookings/26');
    expect(answer.links.last.label, 'Xem tour đã đặt');
  });

  test('câu hỏi được cắt khoảng trắng trước khi gửi', () async {
    final ai = _FakeAi();

    await AskGuestAssistant(ai)('   Đơn của tôi?   ');

    expect(ai.asked, 'Đơn của tôi?');
  });

  testWidgets('màn trợ lý: hỏi rồi hiện câu trả lời kèm nút mở đơn', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiGuestAssistantCubit>(() => AiGuestAssistantCubit(AskGuestAssistant(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AiGuestAssistantScreen()));
    await tester.pumpAndSettle();

    expect(find.text(AiStrings.guestExamples.first), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Đơn sắp tới của tôi thế nào?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, 'Đơn sắp tới của tôi thế nào?');
    expect(find.textContaining('Hoàn Kiếm Palace'), findsOneWidget);
    expect(find.text('Xem đơn phòng #26'), findsOneWidget);
    expect(find.text(AiStrings.guestNext.toUpperCase()), findsOneWidget);
    expect(find.text(AiStrings.guestNote), findsOneWidget);
  });
}
