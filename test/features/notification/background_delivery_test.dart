import 'package:booking_app_mobile/features/notification/services/background_delivery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('booking_app/notification_setup');

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  void nativeReturns(Map<String, Object> status) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => call.method == 'status' ? status : true,
    );
  }

  test('Xiaomi chưa bật Tự khởi chạy: chưa sẵn sàng', () async {
    nativeReturns({
      'manufacturer': 'Xiaomi',
      'notificationsEnabled': true,
      'batteryUnrestricted': false,
      'autoStart': 'denied',
    });
    final status = await BackgroundDelivery().status();
    expect(status!.manufacturer, 'Xiaomi');
    expect(status.hasAutoStart, isTrue);
    expect(status.autoStartOk, isFalse);
    expect(status.ready, isFalse);
  });

  test('Xiaomi đã bật đủ: sẵn sàng', () async {
    nativeReturns({
      'manufacturer': 'Xiaomi',
      'notificationsEnabled': true,
      'batteryUnrestricted': true,
      'autoStart': 'allowed',
    });
    expect((await BackgroundDelivery().status())!.ready, isTrue);
  });

  test('Pixel/Samsung không có mục Tự khởi chạy: chỉ cần thông báo + pin', () async {
    nativeReturns({
      'manufacturer': 'Google',
      'notificationsEnabled': true,
      'batteryUnrestricted': true,
      'autoStart': 'notNeeded',
    });
    final status = (await BackgroundDelivery().status())!;
    expect(status.hasAutoStart, isFalse);
    expect(status.ready, isTrue);
  });

  test('Oppo không đọc được Tự khởi chạy: coi là cần kiểm tra', () async {
    nativeReturns({
      'manufacturer': 'OPPO',
      'notificationsEnabled': true,
      'batteryUnrestricted': true,
      'autoStart': 'unknown',
    });
    final status = (await BackgroundDelivery().status())!;
    expect(status.autoStart, AutoStartState.unknown);
    expect(status.ready, isFalse);
  });

  test('ngoài Android: không đọc', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await BackgroundDelivery().status(), isNull);
  });
}
