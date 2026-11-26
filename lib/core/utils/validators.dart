import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../text/validation_strings.dart';

/// Validator dùng chung, khớp ràng buộc phía BE (SĐT `0\d{9}`, username ≥ 6 ký tự…).
abstract final class Validators {
  static final RegExp _phonePattern = RegExp(r'^0\d{9}$');

  static FormFieldValidator<String> required([
    String message = ValidationStrings.required,
  ]) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return ValidationStrings.required;
    return _phonePattern.hasMatch(text) ? null : ValidationStrings.phone;
  }

  static String? optionalPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _phonePattern.hasMatch(text) ? null : ValidationStrings.phone;
  }

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return ValidationStrings.required;
    return _emailPattern.hasMatch(text) ? null : ValidationStrings.email;
  }

  static String? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return ValidationStrings.required;
    if (text.contains(' ')) return ValidationStrings.usernameSpaces;
    return text.length < 6 ? ValidationStrings.usernameLength : null;
  }

  /// Cùng quy tắc với BE (`PasswordPolicy`): ít nhất 8 ký tự và không nằm trong danh sách
  /// mật khẩu bị đoán đầu tiên. "Không trùng tên đăng nhập" BE tự kiểm tra.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return ValidationStrings.required;
    if (value.length < 8) return ValidationStrings.passwordLength;
    // bcrypt chỉ băm 72 byte đầu và BE từ chối mật khẩu dài hơn; chữ có dấu chiếm 2-3 byte.
    if (utf8.encode(value).length > 72) return ValidationStrings.passwordTooLong;
    if (_commonPasswords.contains(value.toLowerCase())) return ValidationStrings.passwordCommon;
    return null;
  }

  static const _commonPasswords = {
    'admin123', 'admin', '123456', '12345678', '123456789', '1234567890', 'password',
    'password1', 'qwerty123', '11111111', '00000000', 'abc12345', 'iloveyou',
  };

  static FormFieldValidator<String> confirmPassword(
    TextEditingController password,
  ) =>
      (value) {
        if (value == null || value.isEmpty) return ValidationStrings.required;
        return value == password.text
            ? null
            : ValidationStrings.passwordMismatch;
      };

  /// Số tiền > 0; chấp nhận dấu chấm/phẩy phân tách hàng nghìn.
  static String? money(String? value) {
    final parsed = parseMoney(value);
    if ((value ?? '').trim().isEmpty) return ValidationStrings.required;
    return parsed == null || parsed <= 0
        ? ValidationStrings.positiveNumber
        : null;
  }

  static String? positiveInt(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return ValidationStrings.required;
    final parsed = int.tryParse(text);
    return parsed == null || parsed <= 0 ? ValidationStrings.wholeNumber : null;
  }

  static double? parseMoney(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : double.tryParse(digits);
  }
}
