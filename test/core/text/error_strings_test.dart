import 'package:booking_app_mobile/core/text/error_strings.dart';
import 'package:booking_app_mobile/core/text/validation_strings.dart';
import 'package:booking_app_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorStrings.translate — bảo vệ khi API lên Internet', () {
    test('khoá đăng nhập sau nhiều lần sai (1021)', () {
      expect(
        ErrorStrings.translate(
          'Too many failed logins, try again in a few minutes',
          code: 1021,
          status: 429,
        ),
        contains('15 phút'),
      );
    });

    test('quá nhiều đăng ký từ một địa chỉ (1023) hiện nguyên câu tiếng Việt',
        () {
      const raw = 'Quá nhiều yêu cầu từ địa chỉ này, thử lại sau ít phút';
      expect(ErrorStrings.translate(raw, code: 1023, status: 429), raw);
    });

    test('ảnh không hợp lệ (1022) hiện nguyên câu tiếng Việt', () {
      const raw = 'Chỉ nhận ảnh JPEG, PNG, WEBP hoặc GIF';
      expect(ErrorStrings.translate(raw, code: 1022, status: 400), raw);
    });

    test('lỗi máy chủ kèm mã tra cứu giữ lại mã để người dùng báo lại', () {
      const raw = 'Lỗi không mong muốn ở máy chủ (mã tra cứu: 7f2b61c7)';
      expect(ErrorStrings.translate(raw, code: 999, status: 500),
          contains('7f2b61c7'));
    });

    test('429 không có thông điệp vẫn ra câu tiếng Việt', () {
      expect(ErrorStrings.translate(null, status: 429),
          ErrorStrings.tooManyRequests);
    });
  });

  group('ErrorStrings.translate — luồng duyệt chủ khách sạn', () {
    test('chủ khách sạn chưa được duyệt', () {
      expect(
        ErrorStrings.translate('Hotel owner account is not approved yet',
            code: 1011),
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
