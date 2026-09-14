import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../color/status_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'app_network_image.dart';

/// Ảnh đại diện: ảnh nếu có, không thì chữ cái đầu của tên.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.size = 44,
    this.tone = StatusTone.brand,
  });

  final String? name;
  final String? imagePath;
  final double size;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    final initials = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
      child: Text(
        Fmt.initials(name),
        style: AppTextStyles.bodyStrong.copyWith(
          fontSize: size * 0.36,
          color: colors.foreground,
        ),
      ),
    );
    if ((imagePath ?? '').isEmpty) return initials;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: AppNetworkImage(path: imagePath, placeholderIcon: Icons.person),
      ),
    );
  }
}

/// Sao đánh giá 0–5. BE trả `rating` là số nguyên.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 15,
    this.color = AppColors.accent,
  });

  final num rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = rating.clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < value ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: index < value ? color : AppColors.line,
        ),
      ),
    );
  }
}

class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 42,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          onPressed: () => onChanged(star),
          iconSize: size,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            star <= value ? Icons.star_rounded : Icons.star_outline_rounded,
            color: star <= value ? AppColors.accent : AppColors.line,
          ),
        );
      }),
    );
  }
}

/// Giá kèm đơn vị nhỏ: "850.000 ₫/đêm".
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.unit,
    this.style,
    this.color = AppColors.ink,
  });

  final num? amount;
  final String? unit;
  final TextStyle? style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTextStyles.money;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: Fmt.money(amount), style: base.colored(color)),
          if (unit != null)
            TextSpan(text: unit, style: AppTextStyles.caption),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Biểu tượng nhỏ + dòng chữ (địa chỉ, số điện thoại, sức chứa).
class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.style,
    this.iconColor = AppColors.inkTertiary,
    this.maxLines = 1,
    this.iconSize = 16,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;
  final Color iconColor;
  final int maxLines;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: style ?? AppTextStyles.bodySmall,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dòng nhãn – giá trị trong thẻ chi tiết.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.icon,
    this.valueStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 7),
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final IconData? icon;
  final TextStyle? valueStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.inkTertiary),
            const SizedBox(width: 10),
          ],
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value,
                    style: valueStyle ?? AppTextStyles.bodyMedium,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ số liệu (KPI) — biểu tượng theo tông, nhãn, số lớn, chú thích.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone = StatusTone.brand,
    this.caption,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final StatusTone tone;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 17, color: colors.foreground),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.colored(AppColors.inkSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.metric),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Logo chữ nhật bo góc của app.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.onPrimary.withValues(alpha: 0.16)
            : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: onDark
            ? Border.all(color: AppColors.onPrimary.withValues(alpha: 0.28))
            : null,
      ),
      child: Icon(
        Icons.king_bed_rounded,
        size: size * 0.52,
        color: AppColors.onPrimary,
      ),
    );
  }
}

/// Vùng đầu trang nền xanh ngọc chuyển màu, bo tròn cạnh dưới.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
    this.bottomRadius = AppRadius.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.onPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}
