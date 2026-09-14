import 'dart:async';

import 'package:injectable/injectable.dart';

/// Kênh báo "phiên đăng nhập đã hết hạn" từ tầng mạng lên tầng giao diện,
/// để `core` không phải phụ thuộc ngược vào feature auth.
@lazySingleton
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get onExpired => _expired.stream;

  void notifyExpired() {
    if (!_expired.isClosed) _expired.add(null);
  }

  @disposeMethod
  void dispose() => _expired.close();
}
