import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';

/// Tiền đã ghi nhận thu trong ngày, theo phương thức — để đối chiếu quỹ cuối ca.
class TodayCollectionsCard extends StatelessWidget {
  const TodayCollectionsCard({super.key, required this.collections});

  final Collections collections;

  @override
  Widget build(BuildContext context) {
    final methods = collections.byMethod.where((share) => share.count > 0).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: ReportStrings.todayCollected),
          const Gap(AppSpacing.sm),
          if (collections.payments == 0)
            Text(ReportStrings.nothingCollectedToday, style: AppTextStyles.bodySmall)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Fmt.money(collections.total),
                      style: AppTextStyles.moneyLarge.colored(AppColors.success),
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(ReportStrings.collectionsTotal(collections.payments), style: AppTextStyles.caption),
                ),
              ],
            ),
            const Gap(AppSpacing.xs),
            for (final share in methods)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(PaymentMethod.parse(share.key).label, style: AppTextStyles.bodySmall),
                    ),
                    Text(Fmt.money(share.revenue), style: AppTextStyles.tabular.weight(FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
