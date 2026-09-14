import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:requests_inspector/requests_inspector.dart';

import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi');
  await configureDependencies();
  runApp(
    // Trình xem request chỉ bật ở bản debug. Điện thoại: lắc máy hoặc nhấn giữ
    // màn hình; web/desktop: nhấn giữ màn hình. Request được ghi nhờ
    // `RequestsInspectorInterceptor` gắn trong `AppModule.dio`.
    const RequestsInspector(
      enabled: kDebugMode,
      hideInspectorBanner: true,
      child: BookingApp(),
    ),
  );
}
