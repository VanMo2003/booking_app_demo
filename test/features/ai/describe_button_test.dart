import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/core/text/app_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai_status.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/describe_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeAi implements AiRepository {
  DescribableKind? askedKind;
  int? askedId;

  @override
  Future<AiStatus> status() async => const AiStatus(enabled: true);

  @override
  Future<DescriptionDraft> draftDescription({
    required DescribableKind kind,
    required int id,
    String? notes,
  }) async {
    askedKind = kind;
    askedId = id;
    return AiModels.descriptionDraft({
      'description': 'Phòng Deluxe 301 ngủ được 3 khách, có ban công riêng.',
      'highlights': ['3 khách', 'Ban công riêng'],
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, TextEditingController controller, int? id) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AiDescribeButton(kind: DescribableKind.room, id: id, controller: controller),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _FakeAi ai;

  setUp(() {
    ai = _FakeAi();
    getIt.registerFactory<DraftDescription>(() => DraftDescription(ai));
    getIt.registerSingleton<AiAvailability>(AiAvailability(ai)..enabled.value = true);
  });

  tearDown(getIt.reset);

  test('đọc bản nháp và các ý ngắn', () {
    final draft = AiModels.descriptionDraft({
      'description': 'Bún chả nướng than hoa.',
      'highlights': ['Than hoa'],
      'currentDescription': 'Mô tả cũ.',
      'notes': ['Mục này đã có mô tả; lưu bản mới sẽ thay bản cũ.'],
    });

    expect(draft.description, 'Bún chả nướng than hoa.');
    expect(draft.highlights, ['Than hoa']);
    expect(draft.currentDescription, 'Mô tả cũ.');
    expect(draft.notes, hasLength(1));
  });

  testWidgets('ô trống: soạn xong điền thẳng vào ô nhập', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller, 11);
    await tester.tap(find.text(AiStrings.describeAction));
    await tester.pumpAndSettle();

    expect(ai.askedKind, DescribableKind.room);
    expect(ai.askedId, 11);
    expect(controller.text, startsWith('Phòng Deluxe 301'));
  });

  testWidgets('đã có mô tả: hỏi trước, đồng ý thì mới thay', (tester) async {
    final controller = TextEditingController(text: 'Mô tả cũ của quản lý.');
    addTearDown(controller.dispose);

    await _pump(tester, controller, 11);
    await tester.tap(find.text(AiStrings.describeAction));
    await tester.pumpAndSettle();

    expect(find.text(AiStrings.describeOverwriteTitle), findsOneWidget);
    await tester.tap(find.text(AiStrings.describeOverwriteConfirm).last);
    await tester.pumpAndSettle();

    expect(ai.askedId, 11);
    expect(controller.text, startsWith('Phòng Deluxe 301'));
  });

  testWidgets('đã có mô tả: bấm huỷ thì không gọi AI và giữ nguyên chữ cũ', (tester) async {
    final controller = TextEditingController(text: 'Mô tả cũ của quản lý.');
    addTearDown(controller.dispose);

    await _pump(tester, controller, 11);
    await tester.tap(find.text(AiStrings.describeAction));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.cancel).last);
    await tester.pumpAndSettle();

    expect(ai.askedId, isNull);
    expect(controller.text, 'Mô tả cũ của quản lý.');
  });

  testWidgets('mục chưa lưu lần nào: nói thẳng là phải lưu trước, không gọi AI', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller, null);
    await tester.tap(find.text(AiStrings.describeAction));
    await tester.pumpAndSettle();

    expect(ai.askedId, isNull);
    expect(controller.text, isEmpty);
    expect(find.text(AiStrings.describeNeedsSave), findsOneWidget);
  });
}
