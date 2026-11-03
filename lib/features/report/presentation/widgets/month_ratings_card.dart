import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';

/// Điểm đánh giá từ đầu tháng và cảnh báo khi có đánh giá thấp cần liên hệ lại khách.
class MonthRatingsCard extends StatelessWidget {
  const MonthRatingsCard({super.key, required this.ratings});

  final RatingReport ratings;

  @override
  Widget build(BuildContext context) {
    final average = ratings.averageRating;
    final low = ratings.lowReviews.length;
    final danger = StatusTone.danger.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.monthRatingsTitle),
          const Gap(AppSpacing.xs),
          Text(
            average == null
                ? ReportStrings.noReviews
                : ReportStrings.monthRatings(Fmt.decimal(average), ratings.reviews),
            style: average == null
                ? AppTextStyles.bodySmall
                : AppTextStyles.tabular.weight(FontWeight.w600).colored(AppColors.warning),
          ),
          if (low > 0) ...[
            const Gap(AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(color: danger.background, borderRadius: AppRadius.smAll),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.star_half_rounded, size: 18, color: danger.foreground),
                    const Gap(AppSpacing.xs),
                    Expanded(
                      child: Text(
                        ReportStrings.lowReviewsAlert(low),
                        style: AppTextStyles.bodySmall.colored(danger.foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
