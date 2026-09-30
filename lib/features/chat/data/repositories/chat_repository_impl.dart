import 'package:injectable/injectable.dart';

import '../../../../core/network/json_reader.dart';
import '../../../../core/network/paged.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_api.dart';
import '../models/chat_models.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._api);

  final ChatApi _api;

  @override
  Future<Conversation> open(int hotelId) async =>
      (await _api.open({'hotelId': hotelId})).parse(ConversationModel.fromJson);

  @override
  Future<Paged<Conversation>> mine({required int page, required int size}) async =>
      (await _api.mine(page, size)).parsePage(ConversationModel.fromJson);

  @override
  Future<Paged<Conversation>> inbox({int? hotelId, required int page, required int size}) async =>
      (await _api.inbox(hotelId, page, size)).parsePage(ConversationModel.fromJson);

  @override
  Future<int> unreadCount({int? hotelId}) async =>
      (await _api.unreadCount(hotelId)).parse((json) => json.integer('unread'));

  @override
  Future<Conversation> getById(int id) async =>
      (await _api.getById(id)).parse(ConversationModel.fromJson);

  @override
  Future<List<ChatMessage>> messages(int conversationId, {int? beforeId, int size = 30}) async =>
      (await _api.messages(conversationId, beforeId, size)).parseList(ChatMessageModel.fromJson);

  @override
  Future<ChatMessage> send(int conversationId, String content) async =>
      (await _api.send(conversationId, {'content': content})).parse(ChatMessageModel.fromJson);

  @override
  Future<Conversation> markRead(int conversationId) async =>
      (await _api.markRead(conversationId)).parse(ConversationModel.fromJson);
}
