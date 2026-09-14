import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/app_text_styles.dart';

/// Ô nhập chuẩn; mọi viền, màu, nhãn lấy từ `InputDecorationTheme`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.suffixText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: AppTextStyles.body,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        errorMaxLines: 2,
        counterText: '',
        suffixText: suffixText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffix,
        alignLabelWithHint: (maxLines ?? 1) > 1,
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _hidden,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      suffix: IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
      ),
    );
  }
}

/// Ô nhập số tiền, tự chèn dấu chấm hàng nghìn: 1050000 → 1.050.000.
class AppMoneyField extends StatelessWidget {
  const AppMoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.helper,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final String? helper;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      helper: helper,
      prefixIcon: Icons.payments_outlined,
      suffixText: '₫',
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      inputFormatters: [ThousandsInputFormatter()],
      validator: validator,
    );
  }
}

class ThousandsInputFormatter extends TextInputFormatter {
  static String format(num? value) {
    if (value == null) return '';
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final trimmed = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final text = format(int.parse(trimmed.length > 15 ? trimmed.substring(0, 15) : trimmed));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
