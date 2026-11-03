import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';
import 'target_progress_card.dart';

/// Dòng "đã đặt bao nhiêu" của một cơ sở trong danh sách cơ sở của chuỗi: vạch đậm là phần đã đặt, vạch nhạt là
/// mức của chính những đêm đó năm trước.
class BranchOutlookLine extends StatelessWidget {
  const BranchOutlookLine({super.key, required this.outlook, this.days = AppConstants.outlookDays});

  final BranchOutlook outlook;
  final int days;

  @override
  Widget build(BuildContext context) {
    final lastYear = outlook.lastYearOccupancy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ReportStrings.branchOnTheBooks(
            days,
            Fmt.percent(outlook.occupancyOnTheBooks),
            lastYear == null ? null : Fmt.percent(lastYear),
          ),
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        TargetBar(
          height: 6,
          achieved: outlook.occupancyOnTheBooks / 100,
          projected: (lastYear ?? 0) / 100,
        ),
      ],
    );
  }
}
