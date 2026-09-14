import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';

enum AppButtonVariant { primary, tonal, secondary, danger, dangerOutline, text }

enum AppButtonSize { large, medium, small }

/// Nút chuẩn của app. Đang [loading] thì hiện vòng xoay và chặn bấm lặp.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.danger;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.large => 52.0,
      AppButtonSize.medium => 44.0,
      AppButtonSize.small => 36.0,
    };
    final horizontal = switch (size) {
      AppButtonSize.large => AppSpacing.lg,
      AppButtonSize.medium => AppSpacing.md,
      AppButtonSize.small => AppSpacing.sm,
    };
    final textStyle = size == AppButtonSize.small
        ? AppTextStyles.chip.weight(FontWeight.w600)
        : AppTextStyles.button;
    final foreground = _foreground();
    final radius = size == AppButtonSize.small ? AppRadius.smAll : AppRadius.mdAll;

    final content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: size == AppButtonSize.small ? 16 : 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final minimumSize = Size(expand ? double.infinity : 0, height);
    final padding = EdgeInsets.symmetric(horizontal: horizontal);
    final shape = RoundedRectangleBorder(borderRadius: radius);

    final Widget button = switch (variant) {
      AppButtonVariant.primary ||
      AppButtonVariant.tonal ||
      AppButtonVariant.danger =>
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: _background(),
            foregroundColor: foreground,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: textStyle,
          ),
          child: content,
        ),
      AppButtonVariant.secondary || AppButtonVariant.dangerOutline =>
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground,
            side: BorderSide(
              color: variant == AppButtonVariant.dangerOutline
                  ? AppColors.danger.withValues(alpha: 0.45)
                  : AppColors.line,
            ),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: textStyle,
          ),
          child: content,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: textStyle,
          ),
          child: content,
        ),
    };

    return AbsorbPointer(absorbing: loading, child: button);
  }

  Color _background() => switch (variant) {
        AppButtonVariant.tonal => AppColors.primarySoft,
        AppButtonVariant.danger => AppColors.danger,
        _ => AppColors.primary,
      };

  Color _foreground() => switch (variant) {
        AppButtonVariant.primary || AppButtonVariant.danger => AppColors.onPrimary,
        AppButtonVariant.tonal => AppColors.primaryDark,
        AppButtonVariant.secondary => AppColors.ink,
        AppButtonVariant.dangerOutline => AppColors.danger,
        AppButtonVariant.text => AppColors.primary,
      };
}

/// Nút tròn nhỏ đặt trên ảnh (quay lại, yêu thích).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.ink,
    this.background = AppColors.surface,
    this.size = 40,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color background;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: color),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
