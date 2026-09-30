import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/menu_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/dish.dart';

/// Một dòng thực đơn: ảnh vuông, tên, mô tả ngắn, giá. Món tạm hết hiện mờ
/// kèm nhãn — vẫn nằm trên thực đơn.
class DishTile extends StatelessWidget {
  const DishTile({super.key, required this.dish, this.onTap, this.trailing});

  final Dish dish;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dimmed = !dish.available;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(10, 10, trailing == null ? 14 : 2, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: dimmed ? 0.45 : 1,
            child: AppNetworkImage(
              path: dish.pathImage,
              width: 76,
              height: 76,
              borderRadius: AppRadius.smAll,
              placeholderIcon: Icons.restaurant_rounded,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: AppTextStyles.bodyStrong.colored(
                    dimmed ? AppColors.inkTertiary : AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dish.description.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    dish.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      Fmt.money(dish.price),
                      style: AppTextStyles.money.colored(
                        dimmed ? AppColors.inkTertiary : AppColors.primaryDark,
                      ),
                    ),
                    if (dimmed)
                      const StatusBadge(
                        label: MenuStrings.unavailable,
                        tone: StatusTone.neutral,
                        dense: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Thẻ món nhỏ cho dải xem trước thực đơn ở trang chi tiết cơ sở.
class DishPreviewCard extends StatelessWidget {
  const DishPreviewCard({super.key, required this.dish, this.onTap});

  static const width = 148.0;

  final Dish dish;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimmed = !dish.available;
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: dimmed ? 0.45 : 1,
              // AppCard đã bo góc và cắt nội dung, ảnh không cần bo riêng.
              child: AppNetworkImage(
                path: dish.pathImage,
                width: width,
                height: 100,
                placeholderIcon: Icons.restaurant_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    dimmed ? MenuStrings.unavailable : Fmt.money(dish.price),
                    style: dimmed
                        ? AppTextStyles.caption
                        : AppTextStyles.captionStrong.colored(AppColors.primaryDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
