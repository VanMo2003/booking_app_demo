import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/component/feedback.dart';
import '../../../core/enums/app_enums.dart';
import '../../auth/domain/entities/session.dart';
import '../domain/entities/chat.dart';
import '../domain/usecases/chat_usecases.dart';
import '../services/chat_socket.dart';

/// Tổng số tin chưa đọc của người đang đăng nhập (số trên tab Tin nhắn).
@lazySingleton
class ChatUnreadCubit extends Cubit<int> {
  ChatUnreadCubit(this._count) : super(0);

  final GetChatUnreadCount _count;

  Future<void> refresh() async {
    try {
      final unread = await _count();
      if (!isClosed) emit(unread);
    } catch (_) {
      // Giữ số cũ khi mất mạng.
    }
  }

  void reset() => emit(0);
}

/// Nối kênh chat với phiên đăng nhập và vòng đời app:
/// - đăng nhập (trừ quản trị viên): mở WebSocket, đếm tin chưa đọc;
/// - app xuống nền: đóng kết nối để máy chủ gửi thông báo đẩy thay thế;
/// - có tin mới khi đang ở màn khác: hiện toast và cập nhật số chưa đọc.
@lazySingleton
class ChatHub {
  ChatHub(this._socket, this._unread) {
    _socket.refreshSession = _unread.refresh;
    _socket.events.listen(_onEvent);
  }

  final ChatSocket _socket;
  final ChatUnreadCubit _unread;

  Session? _session;
  bool _foreground = true;
  Timer? _refreshDebounce;

  /// Cuộc trò chuyện đang mở trên màn hình — không toast tin của chính nó.
  int? activeConversationId;

  bool isViewing(int conversationId) => activeConversationId == conversationId;

  bool get _canChat => _session != null && _session!.role != Role.admin;

  void onSession(Session? session) {
    _session = session;
    if (!_canChat) {
      _socket.disconnect();
      _unread.reset();
      activeConversationId = null;
      return;
    }
    _unread.refresh();
    if (_foreground) _socket.connect();
  }

  void onLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_foreground) return;
        _foreground = true;
        if (!_canChat) return;
        _unread.refresh();
        _socket.connect();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (!_foreground) return;
        _foreground = false;
        _socket.disconnect();
      case AppLifecycleState.inactive:
        // Kéo thanh thông báo, hộp thoại hệ thống: vẫn đang xem app.
        break;
    }
  }

  void _onEvent(ChatEvent event) {
    if (event.type == ChatEventType.connected) {
      _scheduleUnreadRefresh();
      return;
    }
    _scheduleUnreadRefresh();
    final conversation = event.conversation;
    final message = event.message;
    if (event.type != ChatEventType.message || conversation == null || message == null) return;
    if (message.senderSide == conversation.mySide || isViewing(conversation.id)) return;
    final from = conversation.isCustomerView ? conversation.hotelName : conversation.customerName;
    AppToast.infoGlobal('$from: ${message.content}');
  }

  void _scheduleUnreadRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 300), _unread.refresh);
  }
}
