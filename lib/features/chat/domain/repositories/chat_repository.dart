import '../../../../core/network/paged.dart';
import '../entities/chat.dart';

abstract interface class ChatRepository {
  /// Khách hàng mở (hoặc mở lại) cuộc trò chuyện với cơ sở.
  Future<Conversation> open(int hotelId);

  Future<Paged<Conversation>> mine({required int page, required int size});

  /// Hộp thư phía cơ sở; [hotelId] rỗng = mọi cơ sở người dùng phụ trách.
  Future<Paged<Conversation>> inbox({int? hotelId, required int page, required int size});

  Future<int> unreadCount({int? hotelId});

  /// Vé dùng một lần (60 giây) để mở `/ws/chat?ticket=…`, thay cho access token trong URL.
  Future<String> wsTicket();

  Future<Conversation> getById(int id);

  /// Mới nhất trước; truyền [beforeId] để tải tin cũ hơn.
  Future<List<ChatMessage>> messages(int conversationId, {int? beforeId, int size = 30});

  Future<ChatMessage> send(int conversationId, String content);

  Future<Conversation> markRead(int conversationId);
}
