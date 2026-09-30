import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/bloc/paged_cubit.dart';
import '../../../../core/network/paged.dart';
import '../../domain/entities/chat.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../services/chat_socket.dart';

/// Hộp thư: phân trang qua REST, cập nhật tại chỗ theo sự kiện WebSocket —
/// tin mới đẩy cuộc trò chuyện lên đầu, "đã đọc" cập nhật số chưa đọc.
@injectable
class ConversationsCubit extends PagedCubit<Conversation> {
  ConversationsCubit(this._getConversations, this._socket);

  final GetConversations _getConversations;
  final ChatSocket _socket;

  late bool _asCustomer;
  int? _hotelId;
  StreamSubscription<ChatEvent>? _events;

  Future<void> start({required bool asCustomer, int? hotelId}) {
    _asCustomer = asCustomer;
    _hotelId = hotelId;
    _events ??= _socket.events.listen(_onEvent);
    return load();
  }

  @override
  Future<Paged<Conversation>> fetch({required int page, required int size}) =>
      _getConversations(asCustomer: _asCustomer, hotelId: _hotelId, page: page, size: size);

  void _onEvent(ChatEvent event) {
    if (event.type == ChatEventType.connected) {
      // Vừa nối lại: có thể đã lỡ tin trong lúc mất kết nối.
      if (state.status == ViewStatus.success) load();
      return;
    }
    final conversation = event.conversation;
    if (conversation == null || state.status != ViewStatus.success) return;
    if (conversation.isCustomerView != _asCustomer) return;
    if (_hotelId != null && conversation.hotelId != _hotelId) return;

    final items = [...state.items];
    final index = items.indexWhere((item) => item.id == conversation.id);
    if (event.type == ChatEventType.message) {
      if (index >= 0) items.removeAt(index);
      items.insert(0, conversation);
      emit(state.copyWith(items: items, total: index < 0 ? state.total + 1 : state.total));
    } else if (index >= 0) {
      items[index] = conversation;
      emit(state.copyWith(items: items));
    }
  }

  @override
  Future<void> close() async {
    await _events?.cancel();
    return super.close();
  }
}
