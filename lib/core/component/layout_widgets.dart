import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/app_strings.dart';
import '../utils/formatters.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Khung trang chuẩn: AppBar trái, tiêu đề + phụ đề.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.bottomBar,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: subtitle == null
            ? Text(title)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
        actions: [...?actions, const SizedBox(width: AppSpacing.xxs)],
        bottom: bottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Thanh cố định dưới đáy chứa nút hành động chính.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

/// Thanh tổng tiền + nút xác nhận (đặt phòng, tạo đơn).
class TotalActionBar extends StatelessWidget {
  const TotalActionBar({
    super.key,
    required this.label,
    required this.amount,
    required this.actionLabel,
    required this.onAction,
    this.detail,
    this.loading = false,
  });

  final String label;
  final num amount;
  final String? detail;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.caption),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Fmt.money(amount),
                    style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(label: actionLabel, onPressed: onAction, loading: loading),
        ],
      ),
    );
  }
}

/// Nhóm menu dạng danh sách trong một thẻ.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(title!.toUpperCase(), style: AppTextStyles.overline),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 64),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive ? AppColors.danger : AppColors.primary;
    final background = destructive ? AppColors.dangerSoft : AppColors.primarySoft;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: foreground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.colored(
                      destructive ? AppColors.danger : AppColors.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            trailing ??
                (onTap == null || destructive
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkTertiary,
                      )),
          ],
        ),
      ),
    );
  }
}

/// Dải chip lọc cuộn ngang.
class ChoiceChipBar<T> extends StatelessWidget {
  const ChoiceChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.countOf,
    this.padding = AppSpacing.pageHorizontal,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T option) labelOf;
  final int? Function(T option)? countOf;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              selected: option == selected,
              onSelected: (_) => onSelected(option),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labelOf(option),
                    style: AppTextStyles.chip.weight(
                      option == selected ? FontWeight.w600 : FontWeight.w500,
                    ).colored(
                      option == selected ? AppColors.primaryDark : AppColors.ink,
                    ),
                  ),
                  if (countOf?.call(option) != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: option == selected
                            ? AppColors.primary
                            : AppColors.surfaceSunk,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${countOf!(option)}',
                        style: AppTextStyles.captionStrong.colored(
                          option == selected
                              ? AppColors.onPrimary
                              : AppColors.inkSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              side: BorderSide(
                color: option == selected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.line,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

/// Thẻ chọn được (phòng, dịch vụ, phương thức thanh toán).
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.multiple = true,
    this.enabled = true,
    this.padding = const EdgeInsets.all(14),
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool multiple;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final indicator = multiple
        ? AnimatedContainer(
            duration: AppDurations.fast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.inkTertiary,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary)
                : null,
          )
        : AnimatedContainer(
            duration: AppDurations.fast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.inkTertiary,
                width: selected ? 6.5 : 1.5,
              ),
            ),
          );
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft.withValues(alpha: 0.55) : AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lineSoft,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  indicator,
                  const SizedBox(width: 12),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiến trình các bước (đặt phòng tại quầy) — đánh số vì thứ tự có ý nghĩa.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i <= current ? AppColors.primary : AppColors.line,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppDurations.normal,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current
                      ? AppColors.primary
                      : i == current
                          ? AppColors.primarySoft
                          : AppColors.surface,
                  border: Border.all(
                    color: i <= current ? AppColors.primary : AppColors.line,
                    width: 1.5,
                  ),
                ),
                child: i < current
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary)
                    : Text(
                        '${i + 1}',
                        style: AppTextStyles.captionStrong.colored(
                          i == current ? AppColors.primaryDark : AppColors.inkTertiary,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: (i == current ? AppTextStyles.captionStrong : AppTextStyles.caption)
                    .colored(i == current ? AppColors.ink : AppColors.inkTertiary),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Ô tìm kiếm có nút xoá nhanh.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: AppStrings.close,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                ),
        ),
      ),
    );
  }
}
