import 'dart:async';

import 'package:injectable/injectable.dart';

/// Báo cho các màn đang mở rằng vừa có thông báo mới (push, kiểm tra định kỳ,
/// quay lại app) để tự tải lại dữ liệu liên quan: trạng thái duyệt, hàng chờ duyệt.
@lazySingleton
class NotificationEvents {
  final _changed = StreamController<void>.broadcast();

  Stream<void> get onChanged => _changed.stream;

  void notifyChanged() => _changed.add(null);
}
