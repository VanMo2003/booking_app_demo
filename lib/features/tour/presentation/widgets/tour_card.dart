import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/tour_strings.dart';
import '../../domain/entities/tour.dart';

/// "4 giờ · 8:00 hằng ngày" — những gì có thì ghép lại.
String tourMeta(Tour tour) =>
    [tour.duration, tour.departure].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

/// Một dòng tour: ảnh, tên, thời lượng/khởi hành, giá mỗi khách. Tour tạm ngừng hiện mờ kèm nhãn.
class TourCard extends StatelessWidget {
  const TourCard({super.key, required this.tour, this.onTap, this.trailing});

  final Tour tour;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final paused = !tour.available;
    final meta = tourMeta(tour);
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(10, 10, trailing == null ? 14 : 2, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: paused ? 0.45 : 1,
            child: AppNetworkImage(
              path: tour.pathImage,
              width: 96,
              height: 80,
              borderRadius: AppRadius.smAll,
              placeholderIcon: Icons.tour_outlined,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.name,
                  style: AppTextStyles.bodyStrong.colored(paused ? AppColors.inkTertiary : AppColors.ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty) ...[
                  const Gap(2),
                  IconText(icon: Icons.schedule_rounded, iconSize: 14, text: meta, style: AppTextStyles.caption),
                ],
                const Gap(6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PriceText(
                      tour.price,
                      unit: TourStrings.perGuest,
                      color: paused ? AppColors.inkTertiary : AppColors.primaryDark,
                    ),
                    if (paused)
                      const StatusBadge(label: TourStrings.paused, tone: StatusTone.neutral, dense: true),
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
