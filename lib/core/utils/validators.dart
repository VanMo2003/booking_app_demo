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

  static String? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return ValidationStrings.required;
    if (text.contains(' ')) return ValidationStrings.usernameSpaces;
    return text.length < 6 ? ValidationStrings.usernameLength : null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return ValidationStrings.required;
    return value.length < 6 ? ValidationStrings.passwordLength : null;
  }

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
