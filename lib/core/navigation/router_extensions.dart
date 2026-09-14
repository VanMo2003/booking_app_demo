import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

extension RootRouterX on BuildContext {
  /// Router gốc — dùng để mở trang toàn màn hình từ bên trong một tab.
  StackRouter get rootRouter => router.root;
}
