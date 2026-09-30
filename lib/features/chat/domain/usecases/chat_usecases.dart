import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

@injectable
class OpenConversation {
  const OpenConversation(this._repository);

  final ChatRepository _repository;

  Future<Conversation> call(int hotelId) => _repository.open(hotelId);
}

@injectable
class GetConversations {
  const GetConversations(this._repository);

  final ChatRepository _repository;

  /// Khách hàng: các cuộc trò chuyện của mình. Phía cơ sở: hộp thư chung,
  /// lọc theo [hotelId] nếu có.
  Future<Paged<Conversation>> call({
    required bool asCustomer,
    int? hotelId,
    required int page,
    required int size,
  }) =>
      asCustomer
          ? _repository.mine(page: page, size: size)
          : _repository.inbox(hotelId: hotelId, page: page, size: size);
}

@injectable
class GetConversation {
  const GetConversation(this._repository);

  final ChatRepository _repository;

  Future<Conversation> call(int id) => _repository.getById(id);
}

@injectable
class GetChatMessages {
  const GetChatMessages(this._repository);

  final ChatRepository _repository;

  Future<List<ChatMessage>> call(int conversationId, {int? beforeId, int size = 30}) =>
      _repository.messages(conversationId, beforeId: beforeId, size: size);
}

@injectable
class SendChatMessage {
  const SendChatMessage(this._repository);

  final ChatRepository _repository;

  Future<ChatMessage> call(int conversationId, String content) =>
      _repository.send(conversationId, content.trim());
}

@injectable
class MarkConversationRead {
  const MarkConversationRead(this._repository);

  final ChatRepository _repository;

  Future<Conversation> call(int conversationId) => _repository.markRead(conversationId);
}

@injectable
class GetChatUnreadCount {
  const GetChatUnreadCount(this._repository);

  final ChatRepository _repository;

  Future<int> call() => _repository.unreadCount();
}
