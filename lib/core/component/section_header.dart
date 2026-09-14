import 'package:flutter/material.dart';

import '../style/app_text_styles.dart';

/// Tiêu đề một nhóm nội dung, kèm hành động phụ ("Xem tất cả").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: AppTextStyles.chip.weight(FontWeight.w600),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Nhãn nhóm nhỏ viết hoa (menu, form dài).
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(text.toUpperCase(), style: AppTextStyles.overline),
    );
  }
}
