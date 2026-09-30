import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

/// Cuộc trò chuyện giữa một khách hàng và một cơ sở, nhìn từ phía [mySide]:
/// [unread] là số tin phía bên kia gửi mà phía mình chưa mở.
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.customerId,
    required this.customerName,
    required this.mySide,
    this.hotelAddress = '',
    this.hotelPhone = '',
    this.hotelImage,
    this.customerPhone = '',
    this.customerImage,
    this.lastMessage = '',
    this.lastSenderSide,
    this.lastMessageAt,
    this.unread = 0,
    this.needsStaff = false,
    this.handoffReason,
  });

  final int id;
  final int hotelId;
  final String hotelName;
  final String hotelAddress;
  final String hotelPhone;
  final String? hotelImage;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String? customerImage;
  final String lastMessage;
  final ChatSide? lastSenderSide;
  final DateTime? lastMessageAt;
  final ChatSide mySide;
  final int unread;

  /// Trợ lý AI đã chuyển cuộc này cho nhân viên (chỉ phía cơ sở thấy).
  final bool needsStaff;
  final String? handoffReason;

  bool get isCustomerView => mySide == ChatSide.customer;

  /// Người ở đầu bên kia: khách thấy tên cơ sở, cơ sở thấy tên khách.
  String get counterpartName => isCustomerView ? hotelName : customerName;

  String? get counterpartImage => isCustomerView ? hotelImage : customerImage;

  String get counterpartPhone => isCustomerView ? hotelPhone : customerPhone;

  bool get lastSentByMe => lastSenderSide == mySide;

  @override
  List<Object?> get props => [
        id,
        hotelId,
        hotelName,
        hotelAddress,
        hotelPhone,
        hotelImage,
        customerId,
        customerName,
        customerPhone,
        customerImage,
        lastMessage,
        lastSenderSide,
        lastMessageAt,
        mySide,
        unread,
        needsStaff,
        handoffReason,
      ];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderSide,
    required this.content,
    required this.sentAt,
    this.senderAccountId,
    this.senderName = '',
    this.senderRole,
    this.aiGenerated = false,
  });

  final int id;
  final int conversationId;
  final ChatSide senderSide;
  final String? senderAccountId;
  final String senderName;
  final Role? senderRole;
  final String content;
  final DateTime sentAt;

  /// Trợ lý AI trả lời thay cơ sở (không có tài khoản gửi).
  final bool aiGenerated;

  @override
  List<Object?> get props =>
      [id, conversationId, senderSide, senderAccountId, senderName, senderRole, content, sentAt, aiGenerated];
}

enum ChatEventType { connected, message, read }

/// Sự kiện đẩy qua WebSocket `/ws/chat`.
class ChatEvent extends Equatable {
  const ChatEvent({required this.type, this.conversation, this.message});

  final ChatEventType type;

  /// Cuộc trò chuyện sau thay đổi, nhìn từ phía người nhận sự kiện.
  final Conversation? conversation;
  final ChatMessage? message;

  @override
  List<Object?> get props => [type, conversation, message];
}
