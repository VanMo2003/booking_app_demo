import 'package:booking_app_mobile/features/notification/services/app_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLink.parse', () {
    test('mở trạng thái duyệt của chủ khách sạn', () {
      expect(AppLink.parse('bookingapp://owner-status'), const OwnerStatusLink());
    });

    test('mở hồ sơ đăng ký theo id', () {
      expect(
        AppLink.parse('bookingapp://owner-registrations/42'),
        const OwnerRegistrationLink(42),
      );
    });

    test('mở hộp thông báo', () {
      expect(AppLink.parse('bookingapp://notifications'), const NotificationsLink());
    });

    test('bỏ qua link lạ, sai scheme hoặc id không phải số', () {
      expect(AppLink.parse('https://example.com/owner-status'), isNull);
      expect(AppLink.parse('bookingapp://owner-registrations/abc'), isNull);
      expect(AppLink.parse('bookingapp://unknown'), isNull);
      expect(AppLink.parse(''), isNull);
      expect(AppLink.parse(null), isNull);
    });
  });
}
