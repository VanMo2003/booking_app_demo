import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../domain/usecases/notification_usecases.dart';
import 'firebase_config.dart';

/// Thông báo đẩy qua Firebase Cloud Messaging.
///
/// Chưa cấu hình Firebase (thiếu `google-services.json` / `--dart-define`) hoặc
/// chạy trên web thì dịch vụ tự tắt: thông báo vẫn có trong app nhờ
/// `AppEventsListener` kiểm tra định kỳ.
@lazySingleton
class PushService {
  PushService(this._registerDevice, this._unregisterDevice);

  final RegisterPushDevice _registerDevice;
  final UnregisterPushDevice _unregisterDevice;

  final _foreground = StreamController<PushMessage>.broadcast();
  final _opened = StreamController<String>.broadcast();

  bool _enabled = false;
  String? _token;
  String? _initialLink;

  bool get enabled => _enabled;

  /// Thông báo tới khi app đang mở — hệ điều hành không tự hiện nên app hiện toast.
  Stream<PushMessage> get onForegroundMessage => _foreground.stream;

  /// Deep link của thông báo người dùng vừa chạm vào khi app chạy nền.
  Stream<String> get onOpened => _opened.stream;

  /// Link của thông báo đã mở app từ trạng thái tắt hẳn; chỉ lấy được một lần.
  String? takeInitialLink() {
    final link = _initialLink;
    _initialLink = null;
    return link;
  }

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      if (Firebase.apps.isEmpty) {
        final options = FirebaseConfig.options;
        await (options == null
            ? Firebase.initializeApp()
            : Firebase.initializeApp(options: options));
      }
      _enabled = true;
      FirebaseMessaging.onMessage.listen((message) => _foreground.add(PushMessage.from(message)));
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final link = message.data['link'];
        if (link is String) _opened.add(link);
      });
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      final link = initial?.data['link'];
      if (link is String) _initialLink = link;
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _token = token;
        _syncToken();
      });
    } catch (error) {
      _enabled = false;
      debugPrint('Firebase chưa được cấu hình — tắt thông báo đẩy: $error');
    }
  }

  /// Gắn thiết bị với tài khoản vừa đăng nhập (xin quyền hiện thông báo lần đầu).
  Future<void> attach() async {
    if (!_enabled) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      _token ??= await FirebaseMessaging.instance.getToken();
      await _syncToken();
    } catch (error) {
      debugPrint('Không đăng ký được thiết bị nhận thông báo: $error');
    }
  }

  /// Gỡ thiết bị trước khi đăng xuất để không nhận thông báo của tài khoản cũ.
  Future<void> detach() async {
    final token = _token;
    if (!_enabled || token == null) return;
    try {
      await _unregisterDevice(token);
    } catch (_) {
      // Mất mạng hoặc phiên đã hết hạn — máy chủ gán lại token ở lần đăng nhập sau.
    }
  }

  Future<void> _syncToken() async {
    final token = _token;
    if (token == null) return;
    try {
      await _registerDevice(token: token, platform: defaultTargetPlatform.name);
    } catch (_) {
      // Chưa đăng nhập: token được gửi lại ở lần [attach] sau.
    }
  }
}

class PushMessage {
  const PushMessage({required this.title, this.body = '', this.link});

  factory PushMessage.from(RemoteMessage message) => PushMessage(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        link: message.data['link'] as String?,
      );

  final String title;
  final String body;
  final String? link;
}
