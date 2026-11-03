import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';

/// Doanh thu sắp tới và những khoản cần xử lý, cho màn Tổng quan của quản lý
/// cơ sở và của chủ chuỗi.
class RevenueOutlookCard extends StatelessWidget {
  const RevenueOutlookCard({
    super.key,
    required this.outlook,
    this.onOpenOverdue,
    this.onOpenOutstanding,
  });

  final RevenueOutlook outlook;

  /// Chạm cảnh báo "quá ngày trả phòng" (ví dụ mở tab Quầy); `null` thì chỉ để đọc.
  final VoidCallback? onOpenOverdue;

  /// Chạm cảnh báo "chưa ghi nhận thanh toán" (mở danh sách tiền chưa thu); `null` thì chỉ để đọc.
  final VoidCallback? onOpenOutstanding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: ReportStrings.outlookTitle(outlook.days),
            subtitle: ReportStrings.outlookNote(Fmt.dayMonth(outlook.from), Fmt.dayMonth(outlook.to)),
          ),
          const Gap(AppSpacing.sm),
          Text(
            Fmt.money(outlook.totalExpected),
            style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
          ),
          const Gap(AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Figure(
                  label: ReportStrings.outlookBookings,
                  value: Fmt.moneyCompact(outlook.bookingRevenue),
                  caption: AppStrings.bookingsCount(outlook.bookings),
                ),
              ),
              Expanded(
                child: _Figure(
                  label: ReportStrings.outlookTours,
                  value: Fmt.moneyCompact(outlook.tourRevenue),
                  caption: AppStrings.bookingsCount(outlook.tours),
                ),
              ),
              Expanded(
                child: _Figure(
                  label: ReportStrings.outlookPrepaid,
                  value: Fmt.moneyCompact(outlook.prepaidRevenue),
                  caption: AppStrings.bookingsCount(outlook.prepaidBookings),
                ),
              ),
            ],
          ),
          if (outlook.awaitingConfirmationBookings > 0) ...[
            const Gap(AppSpacing.xs),
            Text(
              ReportStrings.awaitingConfirmation(
                Fmt.money(outlook.awaitingConfirmationRevenue),
                outlook.awaitingConfirmationBookings,
              ),
              style: AppTextStyles.caption,
            ),
          ],
          const Gap(AppSpacing.md),
          AppBarChart(
            height: 140,
            maxLabels: 6,
            points: [
              for (final day in outlook.byDate)
                ChartPoint(
                  Fmt.dayMonth(day.date),
                  day.total,
                  tooltip: '${Fmt.weekdayDate(day.date)} · ${AppStrings.bookingsCount(day.bookings + day.tours)}',
                ),
            ],
          ),
          if (outlook.totalRooms > 0) ...[
            const Gap(AppSpacing.md),
            _OnTheBooks(outlook: outlook),
          ],
          if (outlook.overdueBookings > 0) ...[
            const Gap(AppSpacing.sm),
            _Alert(
              tone: StatusTone.warning,
              icon: Icons.schedule_rounded,
              text: ReportStrings.overdueStays(outlook.overdueBookings, Fmt.money(outlook.overdueRevenue)),
              onTap: onOpenOverdue,
            ),
          ],
          if (outlook.outstandingBookings > 0) ...[
            const Gap(AppSpacing.sm),
            _Alert(
              tone: StatusTone.danger,
              icon: Icons.money_off_rounded,
              text: ReportStrings.outstandingPayments(
                outlook.outstandingBookings,
                Fmt.money(outlook.outstandingAmount),
              ),
              onTap: onOpenOutstanding,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lấp đầy đã đặt trước cho từng đêm của khoảng dự kiến.
class _OnTheBooks extends StatelessWidget {
  const _OnTheBooks({required this.outlook});

  final RevenueOutlook outlook;

  @override
  Widget build(BuildContext context) {
    if (outlook.bookedRoomNights == 0) {
      return Text(ReportStrings.noBookedRooms(outlook.days), style: AppTextStyles.caption);
    }
    final full = outlook.byDate.where((day) => day.bookedRooms >= outlook.totalRooms).length;
    final busiest = outlook.byDate.reduce((a, b) => b.bookedRooms > a.bookedRooms ? b : a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(ReportStrings.onTheBooks, style: AppTextStyles.caption)),
            Text(
              Fmt.percent(outlook.occupancyOnTheBooks),
              style: AppTextStyles.tabular.weight(FontWeight.w600),
            ),
          ],
        ),
        Text(
          [
            ReportStrings.onTheBooksNote(outlook.bookedRoomNights, outlook.availableRoomNights),
            if (full > 0)
              ReportStrings.fullNights(full)
            else
              ReportStrings.busiestNight(Fmt.weekdayDate(busiest.date), busiest.bookedRooms, outlook.totalRooms),
          ].join(' · '),
          style: AppTextStyles.caption,
        ),
        const Gap(AppSpacing.sm),
        AppLineChart(
          height: 110,
          maxY: 100,
          maxLabels: 6,
          axisFormatter: (value) => '${value.round()}%',
          valueFormatter: Fmt.percent,
          points: [
            for (final day in outlook.byDate)
              ChartPoint(
                Fmt.dayMonth(day.date),
                day.occupancyRate,
                tooltip:
                    '${Fmt.weekdayDate(day.date)} · ${ReportStrings.roomsOccupied(day.bookedRooms, outlook.totalRooms)}',
              ),
          ],
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, required this.caption});

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const Gap(2),
        Text(value, style: AppTextStyles.tabular.weight(FontWeight.w600)),
        Text(caption, style: AppTextStyles.caption),
      ],
    );
  }
}

/// Một việc cần xử lý: đơn quá hạn trả phòng, tiền chưa thu.
class _Alert extends StatelessWidget {
  const _Alert({required this.tone, required this.icon, required this.text, this.onTap});

  final StatusTone tone;
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return Material(
      color: colors.background,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colors.foreground),
              const Gap(AppSpacing.xs),
              Expanded(
                child: Text(text, style: AppTextStyles.bodySmall.colored(colors.foreground)),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, size: 18, color: colors.foreground),
            ],
          ),
        ),
      ),
    );
  }
}
