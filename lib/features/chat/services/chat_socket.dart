import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../data/models/chat_models.dart';
import '../domain/entities/chat.dart';

enum ChatConnection { offline, connecting, online }

/// Kênh WebSocket `/ws/chat` nhận tin nhắn theo thời gian thực.
///
/// Chỉ nhận: gửi tin vẫn đi qua REST (`POST /conversations/{id}/messages`).
/// Mất kết nối thì tự nối lại (chờ 2 → 4 → … tối đa 30 giây); mỗi lần nối lại
/// máy chủ gửi `CONNECTED` để các màn tải lại phần tin có thể đã lỡ.
@lazySingleton
class ChatSocket {
  ChatSocket(this._tokens);

  final TokenStorage _tokens;

  static const _heartbeatEvery = Duration(seconds: 25);

  final _events = StreamController<ChatEvent>.broadcast();
  final connection = ValueNotifier(ChatConnection.offline);

  /// Làm mới access token (qua một request REST có interceptor) trước khi nối.
  Future<void> Function()? refreshSession;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeat;
  Timer? _retry;
  bool _wanted = false;
  int _attempt = 0;

  Stream<ChatEvent> get events => _events.stream;

  bool get isOnline => connection.value == ChatConnection.online;

  /// `http://host/booking-app/api/v1` → `ws://host/booking-app/api/v1/ws/chat?token=…`
  static Uri endpoint(String baseUrl, String token) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '${base.path}/ws/chat',
      queryParameters: {'token': token},
    );
  }

  Future<void> connect() async {
    _wanted = true;
    if (_channel != null) return;
    await _open();
  }

  void disconnect() {
    _wanted = false;
    _retry?.cancel();
    _attempt = 0;
    _close();
    connection.value = ChatConnection.offline;
  }

  Future<void> _open() async {
    _retry?.cancel();
    if (!_wanted || _channel != null) return;
    connection.value = ChatConnection.connecting;
    await _tokens.load();
    if (JwtDecoder.isExpired(_tokens.accessToken)) {
      try {
        await refreshSession?.call();
      } catch (_) {
        // Không làm mới được — thử nối rồi chờ lần sau.
      }
    }
    final token = _tokens.accessToken;
    if (!_wanted) return;
    if (token == null || token.isEmpty) {
      connection.value = ChatConnection.offline;
      return;
    }
    final channel = WebSocketChannel.connect(endpoint(AppConfig.baseUrl, token));
    _channel = channel;
    try {
      await channel.ready;
    } catch (_) {
      if (_channel == channel) _channel = null;
      _scheduleRetry();
      return;
    }
    if (!_wanted || _channel != channel) {
      channel.sink.close();
      return;
    }
    _attempt = 0;
    connection.value = ChatConnection.online;
    _subscription = channel.stream.listen(
      _onData,
      onDone: () => _onClosed(channel),
      onError: (_) => _onClosed(channel),
      cancelOnError: true,
    );
    _heartbeat = Timer.periodic(_heartbeatEvery, (_) => channel.sink.add('{"type":"PING"}'));
  }

  void _onData(dynamic raw) {
    if (raw is! String) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      final event = ChatEventModel.fromJson(json);
      if (event != null) _events.add(event);
    } catch (_) {
      // Bỏ qua khung không đọc được.
    }
  }

  void _onClosed(WebSocketChannel channel) {
    if (_channel != channel) return;
    _close();
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_wanted) {
      connection.value = ChatConnection.offline;
      return;
    }
    connection.value = ChatConnection.offline;
    final delay = Duration(seconds: math.min(30, 2 << math.min(_attempt, 4)));
    _attempt++;
    _retry = Timer(delay, _open);
  }

  void _close() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }
}
