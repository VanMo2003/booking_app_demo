import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/core/utils/formatters.dart';
import 'package:booking_app_mobile/features/chat/data/models/chat_models.dart';
import 'package:booking_app_mobile/features/chat/domain/entities/chat.dart';
import 'package:booking_app_mobile/features/chat/services/chat_socket.dart';
import 'package:booking_app_mobile/features/notification/services/app_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final conversationJson = {
    'id': 5,
    'hotelId': 6,
    'hotelName': 'Khách Sạn Hoàn Kiếm Palace',
    'hotelAddress': 'Hà Nội',
    'hotelPhone': '0386727812',
    'customerId': 9,
    'customerName': 'Nguyễn Văn A',
    'customerPhone': '0912345678',
    'lastMessage': 'Còn phòng không ạ?',
    'lastSenderSide': 'CUSTOMER',
    'lastMessageAt': '2026-09-28T16:20:00.000+00:00',
    'mySide': 'HOTEL',
    'unread': 2,
  };

  group('ConversationModel', () {
    test('phía cơ sở thấy tên khách, tin cuối không phải của mình', () {
      final c = ConversationModel.fromJson(conversationJson);
      expect(c.mySide, ChatSide.hotel);
      expect(c.isCustomerView, isFalse);
      expect(c.counterpartName, 'Nguyễn Văn A');
      expect(c.counterpartPhone, '0912345678');
      expect(c.lastSentByMe, isFalse);
      expect(c.unread, 2);
      expect(c.lastMessageAt, isNotNull);
    });

    test('phía khách thấy tên cơ sở; chưa có tin thì không có người gửi cuối', () {
      final c = ConversationModel.fromJson({
        ...conversationJson,
        'mySide': 'CUSTOMER',
        'lastSenderSide': null,
        'lastMessage': null,
      });
      expect(c.counterpartName, 'Khách Sạn Hoàn Kiếm Palace');
      expect(c.lastSenderSide, isNull);
      expect(c.lastMessage, '');
    });
  });

  group('ChatEventModel', () {
    test('MESSAGE mang cuộc trò chuyện và tin nhắn', () {
      final event = ChatEventModel.fromJson({
        'type': 'MESSAGE',
        'conversation': conversationJson,
        'message': {
          'id': 41,
          'conversationId': 5,
          'senderSide': 'HOTEL',
          'senderAccountId': 'acc-1',
          'senderName': 'Lan',
          'senderRole': 'STAFF',
          'content': 'Dạ còn ạ',
          'onCreate': '2026-09-28T16:21:00.000+00:00',
        },
      })!;
      expect(event.type, ChatEventType.message);
      expect(event.conversation!.id, 5);
      expect(event.message!.senderRole, Role.staff);
      expect(event.message!.senderSide, ChatSide.hotel);
    });

    test('CONNECTED không kèm dữ liệu; PONG và loại lạ bị bỏ qua', () {
      expect(ChatEventModel.fromJson({'type': 'CONNECTED'})!.type, ChatEventType.connected);
      expect(ChatEventModel.fromJson({'type': 'PONG'}), isNull);
      expect(ChatEventModel.fromJson({'foo': 1}), isNull);
    });
  });

  test('địa chỉ WebSocket lấy từ base URL của API', () {
    expect(
      ChatSocket.endpoint('http://10.0.2.2:8080/booking-app/api/v1', 'abc').toString(),
      'ws://10.0.2.2:8080/booking-app/api/v1/ws/chat?token=abc',
    );
    expect(
      ChatSocket.endpoint('https://api.example.com/booking-app/api/v1', 'x.y.z').scheme,
      'wss',
    );
  });

  test('deep link bookingapp://chat/{id}', () {
    expect(AppLink.parse('bookingapp://chat/12'), const ChatLink(12));
    expect(AppLink.parse('bookingapp://chat/abc'), isNull);
  });

  test('Fmt.chatTime: giờ hôm nay, "Hôm qua", thứ trong tuần, ngày', () {
    final now = DateTime(2026, 9, 28, 20);
    expect(Fmt.chatTime(DateTime(2026, 9, 28, 9, 5), now: now), '09:05');
    expect(Fmt.chatTime(DateTime(2026, 9, 27, 23), now: now), 'Hôm qua');
    expect(Fmt.chatTime(DateTime(2026, 9, 24, 10), now: now), 'T5');
    expect(Fmt.chatTime(DateTime(2026, 8, 2, 10), now: now), '02/08');
    expect(Fmt.chatTime(DateTime(2025, 12, 31), now: now), '31/12/25');
  });
}
