import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';

/// Dropdown trong form. Nếu [value] không nằm trong [items] (dữ liệu cũ gõ tay,
/// ví dụ giới tính "nam"), giá trị đó vẫn được giữ lại để không mất dữ liệu.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabel,
    this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T item) itemLabel;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current = value;
    final options = [
      ...items,
      if (current != null && !items.contains(current)) current,
    ];
    return DropdownButtonFormField<T>(
      key: ValueKey<Object?>(current),
      initialValue: current,
      isExpanded: true,
      menuMaxHeight: 360,
      borderRadius: AppRadius.mdAll,
      dropdownColor: AppColors.surface,
      icon: const Icon(Icons.expand_more_rounded),
      style: AppTextStyles.body,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
      ),
      items: options
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }
}
