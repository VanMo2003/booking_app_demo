import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:booking_app_mobile/features/chat/data/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('đọc kết quả tìm kiếm AI: bộ lọc, cơ sở khớp, ghi chú', () {
    final result = AiModels.searchResult({
      'query': 'phòng 2 người ở Hà Đông cuối tuần dưới 2 triệu',
      'summary': 'Phòng 2 khách · Hà Đông · dưới 2.000.000 ₫',
      'filters': {
        'checkin': '2026-10-03',
        'checkout': '2026-10-04',
        'guests': 2,
        'maxPrice': 2000000,
        'areas': ['Hà Đông'],
        'amenities': <String>[],
      },
      'results': [
        {
          'hotelId': 9,
          'name': 'Khách Sạn Hà Đông Sunrise',
          'address': 'So 4 Duong Tran Phu, Ha Dong, Ha Noi',
          'category': 'Khách sạn',
          'rating': 0,
          'matchingRooms': 12,
          'fromPrice': 450000,
          'matchedAmenities': <String>[],
        },
      ],
      'notes': ['Chưa cơ sở nào có tiện ích "Sân golf" nên bỏ qua điều kiện này.'],
    });
    expect(result.filters.hasDates, isTrue);
    expect(result.filters.checkin, DateTime(2026, 10, 3));
    expect(result.filters.guests, 2);
    expect(result.filters.maxPrice, 2000000);
    expect(result.filters.minPrice, isNull);
    expect(result.results.single.matchingRooms, 12);
    expect(result.results.single.fromPrice, 450000);
    expect(result.notes, hasLength(1));
  });

  test('bản nháp AI và cài đặt tự trả lời', () {
    final suggestion = AiModels.suggestion({
      'content': 'Dạ còn 20 phòng ạ',
      'needsStaff': false,
      'toolsUsed': ['find_available_rooms'],
    });
    expect(suggestion.toolsUsed, ['find_available_rooms']);
    expect(suggestion.needsStaff, isFalse);

    final settings = AiModels.settings({
      'hotelId': 6,
      'autoReply': true,
      'aiEnabled': true,
      'autoReplyDelaySeconds': 90,
    });
    expect(settings.autoReply, isTrue);
    expect(AiStrings.autoReplyHint(settings.autoReplyDelaySeconds), contains('2 phút'));
    expect(AiStrings.autoReplyHint(30), contains('30 giây'));
  });

  test('tin nhắn do trợ lý AI viết và cờ cần nhân viên', () {
    final message = ChatMessageModel.fromJson({
      'id': 7,
      'conversationId': 2,
      'senderSide': 'HOTEL',
      'senderName': 'Trợ lý AI',
      'content': 'Dạ còn phòng ạ',
      'aiGenerated': true,
      'onCreate': '2026-09-30T11:50:00.000+00:00',
    });
    expect(message.aiGenerated, isTrue);
    expect(message.senderAccountId, isNull);

    final conversation = ConversationModel.fromJson({
      'id': 2,
      'hotelId': 6,
      'hotelName': 'Hoàn Kiếm Palace',
      'customerId': 3,
      'customerName': 'Khách',
      'mySide': 'HOTEL',
      'needsStaff': true,
      'handoffReason': 'Khách muốn huỷ đơn',
    });
    expect(conversation.needsStaff, isTrue);
    expect(AiStrings.handedOff(conversation.handoffReason), contains('huỷ đơn'));
    expect(ConversationModel.fromJson({'id': 1, 'mySide': 'CUSTOMER'}).needsStaff, isFalse);
  });
}
