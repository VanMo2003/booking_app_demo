import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/app_strings.dart';
import '../text/explore_strings.dart';
import '../utils/date_utils.dart';
import '../utils/formatters.dart';

/// Ô chọn một ngày (ngày sinh, tháng lương…).
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.icon = Icons.event_outlined,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData icon;
  final String? errorText;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateOnly.today();
    final first = firstDate ?? DateTime(1950);
    final last = lastDate ?? DateTime(now.year + 5);
    var initial = value ?? now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: label,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.select,
    );
    if (picked != null) onChanged(DateOnly.of(picked));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: AppRadius.smAll,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          enabled: enabled,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: value == null
            ? null
            : Text(Fmt.date(value), style: AppTextStyles.body),
      ),
    );
  }
}

/// Hộp chọn khoảng ngày lưu trú; ngày trả luôn sau ngày nhận ít nhất một đêm.
Future<DateTimeRange?> showStayDatesPicker(
  BuildContext context, {
  DateTime? checkin,
  DateTime? checkout,
}) async {
  final today = DateOnly.today();
  final start = checkin != null && !checkin.isBefore(today) ? checkin : today;
  final end = checkout != null && checkout.isAfter(start)
      ? checkout
      : DateOnly.addDays(start, 1);
  final picked = await showDateRangePicker(
    context: context,
    firstDate: today,
    lastDate: DateOnly.addDays(today, 365),
    initialDateRange: DateTimeRange(start: start, end: end),
    helpText: ExploreStrings.pickDates,
    saveText: AppStrings.done,
    cancelText: AppStrings.cancel,
  );
  if (picked == null) return null;
  final pickedStart = DateOnly.of(picked.start);
  var pickedEnd = DateOnly.of(picked.end);
  if (!pickedEnd.isAfter(pickedStart)) {
    pickedEnd = DateOnly.addDays(pickedStart, 1);
  }
  return DateTimeRange(start: pickedStart, end: pickedEnd);
}

/// Thẻ chọn ngày nhận – trả phòng, hiện số đêm ở giữa.
class StayDatesCard extends StatelessWidget {
  const StayDatesCard({
    super.key,
    required this.checkin,
    required this.checkout,
    required this.onChanged,
    this.enabled = true,
    this.elevated = false,
  });

  final DateTime? checkin;
  final DateTime? checkout;
  final ValueChanged<DateTimeRange> onChanged;
  final bool enabled;
  final bool elevated;

  Future<void> _pick(BuildContext context) async {
    final picked = await showStayDatesPicker(
      context,
      checkin: checkin,
      checkout: checkout,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final nights = checkin != null && checkout != null
        ? DateOnly.nights(checkin!, checkout!)
        : null;
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.line),
            boxShadow: elevated ? AppShadows.card : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: _DateSlot(
                  label: ExploreStrings.checkin,
                  date: checkin,
                  alignEnd: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.inkTertiary,
                    ),
                    if (nights != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          AppStrings.nights(nights),
                          style: AppTextStyles.captionStrong
                              .colored(AppColors.primaryDark),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _DateSlot(
                  label: ExploreStrings.checkout,
                  date: checkout,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSlot extends StatelessWidget {
  const _DateSlot({
    required this.label,
    required this.date,
    required this.alignEnd,
  });

  final String label;
  final DateTime? date;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          date == null ? ExploreStrings.pickDates : Fmt.weekdayDate(date!),
          style: AppTextStyles.subtitle.colored(
            date == null ? AppColors.inkTertiary : AppColors.ink,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
