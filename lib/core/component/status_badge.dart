import 'package:flutter/material.dart';

import '../color/status_colors.dart';
import '../enums/app_enums.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/enum_labels.dart';

/// Viên trạng thái: chấm màu + nhãn. Trạng thái được mã hoá bằng cả màu lẫn
/// hình (chấm), không chỉ bằng chữ.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.dense = false,
  });

  factory StatusBadge.booking(BookingStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.tourBooking(TourBookingStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.payment(PaymentStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.room(RoomStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.hotel(HotelStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.role(Role role, {bool dense = false}) =>
      StatusBadge(label: role.label, tone: role.tone, dense: dense);

  factory StatusBadge.payroll(PayrollStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  factory StatusBadge.approval(ApprovalStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, tone: status.tone, dense: dense);

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: dense ? 12 : 14, color: colors.foreground)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.foreground,
                shape: BoxShape.circle,
              ),
            ),
          SizedBox(width: dense ? 5 : 6),
          Text(
            label,
            style: AppTextStyles.captionStrong.colored(colors.foreground),
          ),
        ],
      ),
    );
  }
}

/// Nhãn phẳng không chấm, cho thông tin phụ (loại hình, "Vãng lai").
class SoftTag extends StatelessWidget {
  const SoftTag({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: colors.foreground),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.caption.colored(colors.foreground)),
        ],
      ),
    );
  }
}
