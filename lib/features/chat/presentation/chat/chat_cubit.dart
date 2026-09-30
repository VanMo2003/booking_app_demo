import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/network/app_exception.dart';
import '../../domain/entities/chat.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../services/chat_socket.dart';
import '../chat_hub.dart';

/// Tin đang gửi (chưa có id máy chủ) hoặc gửi lỗi chờ gửi lại.
class PendingMessage extends Equatable {
  const PendingMessage({required this.localId, required this.content, this.failed = false});

  final String localId;
  final String content;
  final bool failed;

  PendingMessage copyWith({bool? failed}) =>
      PendingMessage(localId: localId, content: content, failed: failed ?? this.failed);

  @override
  List<Object?> get props => [localId, content, failed];
}

class ChatState extends Equatable {
  const ChatState({
    this.conversation,
    this.messages = const [],
    this.pending = const [],
    this.status = ViewStatus.initial,
    this.error,
    this.errorKind,
    this.hasOlder = false,
    this.loadingOlder = false,
    this.olderFailed = false,
  });

  final Conversation? conversation;

  /// Mới nhất trước (khớp danh sách đảo ngược trên màn hình).
  final List<ChatMessage> messages;

  /// Mới nhất trước; luôn nằm dưới cùng, sau các tin đã gửi.
  final List<PendingMessage> pending;
  final ViewStatus status;
  final String? error;
  final AppErrorKind? errorKind;
  final bool hasOlder;
  final bool loadingOlder;
  final bool olderFailed;

  bool get isEmpty => messages.isEmpty && pending.isEmpty;

  ChatState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    List<PendingMessage>? pending,
    ViewStatus? status,
    String? error,
    AppErrorKind? errorKind,
    bool? hasOlder,
    bool? loadingOlder,
    bool? olderFailed,
  }) =>
      ChatState(
        conversation: conversation ?? this.conversation,
        messages: messages ?? this.messages,
        pending: pending ?? this.pending,
        status: status ?? this.status,
        error: error ?? this.error,
        errorKind: errorKind ?? this.errorKind,
        hasOlder: hasOlder ?? this.hasOlder,
        loadingOlder: loadingOlder ?? this.loadingOlder,
        olderFailed: olderFailed ?? this.olderFailed,
      );

  @override
  List<Object?> get props =>
      [conversation, messages, pending, status, error, errorKind, hasOlder, loadingOlder, olderFailed];
}

/// Một cuộc trò chuyện: tải tin theo trang (cũ dần), gửi qua REST, nhận tin mới
/// qua WebSocket, tự đánh dấu đã đọc khi đang mở.
@injectable
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._getConversation,
    this._getMessages,
    this._send,
    this._markRead,
    this._socket,
    this._hub,
  ) : super(const ChatState());

  static const pageSize = 30;

  final GetConversation _getConversation;
  final GetChatMessages _getMessages;
  final SendChatMessage _send;
  final MarkConversationRead _markRead;
  final ChatSocket _socket;
  final ChatHub _hub;

  late int _id;
  StreamSubscription<ChatEvent>? _events;
  Timer? _readDebounce;
  int _localSeq = 0;

  Future<void> start(int conversationId, {Conversation? initial}) {
    _id = conversationId;
    _hub.activeConversationId = conversationId;
    _events ??= _socket.events.listen(_onEvent);
    emit(ChatState(conversation: initial, status: ViewStatus.loading));
    return _loadLatest(initial: true);
  }

  Future<void> retry() => start(_id, initial: state.conversation);

  Future<void> _loadLatest({bool initial = false}) async {
    try {
      final conversation = _getConversation(_id);
      final latest = await _getMessages(_id, size: pageSize);
      final loaded = await conversation;
      if (isClosed) return;
      emit(state.copyWith(
        conversation: loaded,
        messages: _merge(initial ? const [] : state.messages, latest),
        status: ViewStatus.success,
        hasOlder: initial ? latest.length == pageSize : state.hasOlder,
      ));
      _scheduleRead(immediately: true);
    } catch (error) {
      if (isClosed || !initial) return;
      final exception = AppException.from(error);
      emit(state.copyWith(
        status: ViewStatus.failure,
        error: exception.message,
        errorKind: exception.kind,
      ));
    }
  }

  Future<void> loadOlder() async {
    if (!state.hasOlder ||
        state.loadingOlder ||
        state.messages.isEmpty ||
        state.status != ViewStatus.success) {
      return;
    }
    emit(state.copyWith(loadingOlder: true, olderFailed: false));
    try {
      final older = await _getMessages(_id, beforeId: state.messages.last.id, size: pageSize);
      if (isClosed) return;
      emit(state.copyWith(
        messages: _merge(state.messages, older),
        hasOlder: older.length == pageSize,
        loadingOlder: false,
      ));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loadingOlder: false, olderFailed: true));
    }
  }

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    final pending = PendingMessage(localId: 'local-${_localSeq++}', content: content);
    emit(state.copyWith(pending: [pending, ...state.pending]));
    await _deliver(pending);
  }

  Future<void> resend(String localId) async {
    final pending = state.pending.where((p) => p.localId == localId).firstOrNull;
    if (pending == null) return;
    emit(state.copyWith(
      pending: [for (final p in state.pending) p.localId == localId ? p.copyWith(failed: false) : p],
    ));
    await _deliver(pending);
  }

  void discard(String localId) =>
      emit(state.copyWith(pending: state.pending.where((p) => p.localId != localId).toList()));

  Future<void> _deliver(PendingMessage pending) async {
    try {
      final message = await _send(_id, pending.content);
      if (isClosed) return;
      emit(state.copyWith(
        pending: state.pending.where((p) => p.localId != pending.localId).toList(),
        messages: _merge(state.messages, [message]),
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        pending: [
          for (final p in state.pending) p.localId == pending.localId ? p.copyWith(failed: true) : p,
        ],
      ));
    }
  }

  void _onEvent(ChatEvent event) {
    if (event.type == ChatEventType.connected) {
      // Nối lại sau khi mất mạng: lấy phần tin có thể đã lỡ.
      if (state.status == ViewStatus.success) _loadLatest();
      return;
    }
    final conversation = event.conversation;
    if (conversation == null || conversation.id != _id) return;
    final message = event.message;
    if (event.type != ChatEventType.message || message == null) {
      emit(state.copyWith(conversation: conversation));
      return;
    }
    var pending = state.pending;
    if (message.senderSide == conversation.mySide && !state.messages.any((m) => m.id == message.id)) {
      // Tin của chính phía mình về qua socket trước khi REST trả lời: bỏ bản chờ trùng nội dung.
      final index = pending.lastIndexWhere((p) => !p.failed && p.content == message.content);
      if (index >= 0) pending = [...pending]..removeAt(index);
    }
    emit(state.copyWith(
      conversation: conversation,
      messages: _merge(state.messages, [message]),
      pending: pending,
    ));
    if (message.senderSide != conversation.mySide) _scheduleRead();
  }

  void _scheduleRead({bool immediately = false}) {
    _readDebounce?.cancel();
    _readDebounce = Timer(
      immediately ? Duration.zero : const Duration(milliseconds: 400),
      () async {
        if ((state.conversation?.unread ?? 1) == 0) return;
        try {
          final updated = await _markRead(_id);
          if (!isClosed) emit(state.copyWith(conversation: updated));
        } catch (_) {
          // Lần sau mở lại sẽ đánh dấu.
        }
      },
    );
  }

  static List<ChatMessage> _merge(List<ChatMessage> current, List<ChatMessage> incoming) {
    final byId = {for (final m in current) m.id: m, for (final m in incoming) m.id: m};
    return byId.values.toList()..sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Future<void> close() async {
    if (_hub.activeConversationId == _id) _hub.activeConversationId = null;
    _readDebounce?.cancel();
    await _events?.cancel();
    return super.close();
  }
}
