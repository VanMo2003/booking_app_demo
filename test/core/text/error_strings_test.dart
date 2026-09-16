import 'package:booking_app_mobile/core/text/error_strings.dart';
import 'package:booking_app_mobile/core/text/validation_strings.dart';
import 'package:booking_app_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorStrings.translate — luồng duyệt chủ khách sạn', () {
    test('chủ khách sạn chưa được duyệt', () {
      expect(
        ErrorStrings.translate('Hotel owner account is not approved yet', code: 1011),
        ErrorStrings.ownerNotApproved,
      );
    });

    test('quản trị viên chỉ được xem', () {
      expect(
        ErrorStrings.translate('Admin can only view this data', code: 1012),
        ErrorStrings.adminReadOnly,
      );
    });

    test('tên đăng nhập trùng khi đăng ký', () {
      expect(
        ErrorStrings.translate('Account existed with username: owner_1'),
        ErrorStrings.usernameTaken,
      );
    });

    test('lỗi cụ thể được ưu tiên hơn "not found" chung', () {
      expect(
        ErrorStrings.translate('Hotel chain not found for this account'),
        'Tài khoản chưa có hồ sơ khách sạn.',
      );
    });

    test('email sai định dạng từ validation của BE', () {
      expect(
        ErrorStrings.translate('email: invalid email', code: 402),
        'Email không đúng định dạng.',
      );
    });
  });

  test('Validators.email', () {
    expect(Validators.email('owner@example.com'), isNull);
    expect(Validators.email(''), ValidationStrings.required);
    expect(Validators.email('owner@'), ValidationStrings.email);
    expect(Validators.email('owner example.com'), ValidationStrings.email);
  });
}
