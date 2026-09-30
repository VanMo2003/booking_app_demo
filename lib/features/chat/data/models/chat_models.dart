import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/chat.dart';

/// JSON `ConversationResponse` ↔ [Conversation].
abstract final class ConversationModel {
  static Conversation fromJson(Json json) {
    final lastSender = json.strOrNull('lastSenderSide');
    return Conversation(
      id: json.integer('id'),
      hotelId: json.integer('hotelId'),
      hotelName: json.str('hotelName'),
      hotelAddress: json.str('hotelAddress'),
      hotelPhone: json.str('hotelPhone'),
      hotelImage: json.strOrNull('hotelPathImage'),
      customerId: json.integer('customerId'),
      customerName: json.str('customerName'),
      customerPhone: json.str('customerPhone'),
      customerImage: json.strOrNull('customerPathImage'),
      lastMessage: json.str('lastMessage'),
      lastSenderSide: lastSender == null ? null : ChatSide.parse(lastSender),
      lastMessageAt: json.dateTime('lastMessageAt'),
      mySide: ChatSide.parse(json.strOrNull('mySide')),
      unread: json.integer('unread'),
      needsStaff: json.flag('needsStaff'),
      handoffReason: json.strOrNull('handoffReason'),
    );
  }
}

/// JSON `ChatMessageResponse` ↔ [ChatMessage].
abstract final class ChatMessageModel {
  static ChatMessage fromJson(Json json) => ChatMessage(
        id: json.integer('id'),
        conversationId: json.integer('conversationId'),
        senderSide: ChatSide.parse(json.strOrNull('senderSide')),
        senderAccountId: json.strOrNull('senderAccountId'),
        senderName: json.str('senderName'),
        senderRole: Role.tryParse(json.strOrNull('senderRole')),
        content: json.str('content'),
        sentAt: json.dateTime('onCreate') ?? DateTime.now(),
        aiGenerated: json.flag('aiGenerated'),
      );
}

/// Khung sự kiện WebSocket: `{type, conversation?, message?}`. Loại lạ (PONG…) → `null`.
abstract final class ChatEventModel {
  static ChatEvent? fromJson(Json json) {
    final type = switch (json.strOrNull('type')) {
      'CONNECTED' => ChatEventType.connected,
      'MESSAGE' => ChatEventType.message,
      'READ' => ChatEventType.read,
      _ => null,
    };
    if (type == null) return null;
    final conversation = json.obj('conversation');
    final message = json.obj('message');
    return ChatEvent(
      type: type,
      conversation: conversation == null ? null : ConversationModel.fromJson(conversation),
      message: message == null ? null : ChatMessageModel.fromJson(message),
    );
  }
}
