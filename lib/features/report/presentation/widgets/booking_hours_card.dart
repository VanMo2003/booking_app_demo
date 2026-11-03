import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';

/// Bảng nhiệt 7 thứ × 24 giờ: ô càng đậm càng nhiều đơn được tạo vào giờ đó.
class BookingHoursCard extends StatelessWidget {
  const BookingHoursCard({super.key, required this.hours});

  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  final BookingHours hours;

  @override
  Widget build(BuildContext context) {
    final peak = hours.peak;
    final weekday = hours.busiestWeekday;
    final hour = hours.busiestHour;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: ReportStrings.hoursTitle, subtitle: ReportStrings.hoursNote(hours.orders)),
          const Gap(AppSpacing.sm),
          if (hours.orders == 0 || hours.cells.length < 7)
            Text(ReportStrings.noOrders, style: AppTextStyles.bodySmall)
          else ...[
            for (var day = 0; day < 7; day++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Text(_days[day], style: AppTextStyles.caption)),
                    for (var h = 0; h < 24; h++)
                      Expanded(
                        child: Container(
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: _shade(hours.cells[day].length > h ? hours.cells[day][h] : 0, peak),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                const SizedBox(width: 24),
                for (final label in const ['0h', '6h', '12h', '18h'])
                  Expanded(child: Text(label, style: AppTextStyles.caption)),
              ],
            ),
            if (weekday != null && hour != null) ...[
              const Gap(AppSpacing.xs),
              Text(
                ReportStrings.busiestSlot(
                  Fmt.weekdayLong(DateTime(2026, 10, 25 + weekday)),
                  hour,
                  Fmt.percent(hours.nightShare),
                ),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ],
      ),
    );
  }

  static Color _shade(int count, int peak) {
    if (count == 0 || peak == 0) return AppColors.surfaceSunk;
    return AppColors.primary.withValues(alpha: 0.2 + 0.8 * count / peak);
  }
}
