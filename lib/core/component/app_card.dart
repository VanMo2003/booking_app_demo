import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';

/// Bề mặt trắng viền mảnh. Chỉ bật [elevated] cho khối cần nổi lên
/// (thẻ tìm kiếm, thẻ tổng tiền) — không đổ bóng mọi thứ.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.radius = AppRadius.md,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: content,
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? AppColors.lineSoft),
        boxShadow: elevated ? AppShadows.card : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(borderRadius: borderRadius, child: content),
      ),
    );
  }
}
