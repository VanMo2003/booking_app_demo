import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/discover_strings.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour.dart';
import '../../domain/entities/travel_theme.dart';

/// Giá khách trả hôm nay; đang khuyến mãi thì kèm giá gốc gạch ngang.
class TourPriceTag extends StatelessWidget {
  const TourPriceTag({super.key, required this.tour, this.large = false});

  final Tour tour;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = large ? AppTextStyles.moneyLarge : AppTextStyles.money;
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        PriceText(
          tour.salePrice,
          unit: TourStrings.perGuest,
          style: style,
          color: tour.onSale ? AppColors.danger : AppColors.primaryDark,
        ),
        if (tour.onSale)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              Fmt.money(tour.price),
              style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
      ],
    );
  }
}

/// Nhãn "-15%" đặt trên ảnh tour.
class SaleBadge extends StatelessWidget {
  const SaleBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          DiscoverStrings.salePercent(percent),
          style: AppTextStyles.captionStrong.colored(AppColors.onPrimary),
        ),
      ),
    );
  }
}

/// Thẻ tour dọc trong các dải cuộn ngang của trang chủ: ảnh, khuyến mãi, điểm đến, tên, giá.
class TourShelfCard extends StatelessWidget {
  const TourShelfCard({super.key, required this.tour, required this.onTap, this.width = 236});

  final Tour tour;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: AppNetworkImage(path: tour.pathImage, placeholderIcon: Icons.tour_outlined),
                  ),
                ),
                if (tour.onSale && tour.discountPercent != null)
                  Positioned(left: 8, top: 8, child: SaleBadge(percent: tour.discountPercent!)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tour.destination != null)
                    IconText(
                      icon: Icons.place_outlined,
                      iconSize: 14,
                      text: tour.destination!,
                      style: AppTextStyles.caption,
                    ),
                  const Gap(2),
                  Text(tour.name, style: AppTextStyles.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Gap(6),
                  TourPriceTag(tour: tour),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lịch trình tour dạng timeline: chấm và đường nối bên trái, giờ / tiêu đề / mô tả bên phải.
class ItineraryTimeline extends StatelessWidget {
  const ItineraryTimeline({super.key, required this.steps});

  final List<ItineraryStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? AppColors.primary : AppColors.surface,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(child: Container(width: 2, color: AppColors.primarySoft)),
                    ],
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i < steps.length - 1 ? AppSpacing.md : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (steps[i].time != null)
                          Text(steps[i].time!, style: AppTextStyles.captionStrong.colored(AppColors.primaryDark)),
                        Text(steps[i].title, style: AppTextStyles.bodyStrong),
                        if (steps[i].description != null) ...[
                          const Gap(2),
                          Text(steps[i].description!, style: AppTextStyles.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lưới chọn sở thích / chủ đề: mỗi chủ đề một ô có biểu tượng.
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.selected, required this.onChanged});

  final Set<TravelTheme> selected;
  final ValueChanged<Set<TravelTheme>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final theme in TravelTheme.values)
          FilterChip(
            avatar: Icon(theme.icon, size: 18),
            label: Text(theme.label),
            selected: selected.contains(theme),
            onSelected: (on) {
              final next = {...selected};
              on ? next.add(theme) : next.remove(theme);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

/// Các chủ đề của tour dạng nhãn nhỏ.
class ThemeTags extends StatelessWidget {
  const ThemeTags({super.key, required this.themes});

  final List<TravelTheme> themes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final theme in themes)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(theme.icon, size: 14, color: AppColors.primaryDark),
                  const Gap(4),
                  Text(theme.label, style: AppTextStyles.captionStrong.colored(AppColors.primaryDark)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
