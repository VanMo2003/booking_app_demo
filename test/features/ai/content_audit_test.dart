import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/ai/domain/entities/ai.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/ai/presentation/ai_content_audit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _auditJson() => {
      'hotelId': 6,
      'score': 73,
      'summary': 'Trang đã khá đủ, còn thiếu ảnh ở hai phòng và lịch trình của một tour.',
      'checks': [
        {'key': 'hotel_description', 'label': 'Cơ sở có mô tả đủ dài', 'passed': true},
        {
          'key': 'rooms_with_photo',
          'label': 'Mọi phòng đều có ảnh',
          'passed': false,
          'done': 3,
          'total': 5,
          'hint': 'Phòng không ảnh gần như không được chọn.',
        },
        {'key': 'hotel_amenities', 'label': 'Có khai tiện ích chung', 'passed': true, 'done': 6},
      ],
      'items': [
        {
          'title': 'Thêm ảnh cho 2 phòng còn thiếu',
          'priority': 'HIGH',
          'why': 'Phòng không ảnh hiếm khi được khách chọn.',
          'how': 'Mở từng phòng rồi tải ảnh lên.',
          'checkKey': 'rooms_with_photo',
        },
      ],
      'notes': <String>[],
    };

class _FakeAi implements AiRepository {
  int? asked;

  @override
  Future<ContentAudit> contentAudit(int hotelId) async {
    asked = hotelId;
    return AiModels.contentAudit(_auditJson());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc tiêu chí, điểm và việc nên làm', () {
    final audit = AiModels.contentAudit(_auditJson());

    expect(audit.score, 73);
    expect(audit.checks, hasLength(3));
    expect(audit.passedCount, 2);
    expect(audit.checks[1].progress, '3/5');
    expect(audit.checks[2].progress, '6');
    expect(audit.checks.first.progress, isNull);
    expect(audit.items.single.priority, AuditPriority.high);
    expect(audit.items.single.checkKey, 'rooms_with_photo');
  });

  test('mức ưu tiên lạ coi như vừa', () {
    expect(AuditPriority.parse('LOW'), AuditPriority.low);
    expect(AuditPriority.parse('gấp'), AuditPriority.medium);
    expect(AuditPriority.parse(null), AuditPriority.medium);
  });

  testWidgets('màn kiểm tra: điểm, việc nên làm và danh sách tiêu chí', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ai = _FakeAi();
    getIt.registerFactory<AiContentAuditCubit>(() => AiContentAuditCubit(GetContentAudit(ai)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AiContentAuditScreen(hotelId: 6, subtitle: 'Hoàn Kiếm Palace')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ai.asked, 6);
    expect(find.text('73'), findsOneWidget);
    expect(find.text(AiStrings.auditPassed(2, 3)), findsOneWidget);
    expect(find.text(AiStrings.auditHigh), findsOneWidget);
    expect(find.text('Thêm ảnh cho 2 phòng còn thiếu'), findsOneWidget);
    expect(find.text('Mọi phòng đều có ảnh'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
    // Gợi ý của tiêu chí chưa đạt mới hiện, tiêu chí đã đạt không kèm nhắc nhở.
    expect(find.text('Phòng không ảnh gần như không được chọn.'), findsOneWidget);
  });
}
