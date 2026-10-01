import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/ai_strings.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour_booking.dart';

/// Một đơn tour trong danh sách. Khách thấy tour và khách sạn; đội ngũ cơ sở thấy tên khách.
class TourBookingCard extends StatelessWidget {
  const TourBookingCard({super.key, required this.booking, required this.onTap, this.forGuest = true});

  final TourBooking booking;
  final VoidCallback onTap;
  final bool forGuest;

  @override
  Widget build(BuildContext context) {
    final title = forGuest ? booking.tourName : booking.customerName;
    final subtitle = forGuest
        ? '${booking.hotelName} · #${booking.id}'
        : '#${booking.id} · ${booking.tourName}';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                path: booking.tourPathImage,
                width: 52,
                height: 52,
                borderRadius: AppRadius.smAll,
                placeholderIcon: Icons.tour_outlined,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Gap(2),
                    Text(subtitle, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(Fmt.money(booking.totalAmount), style: AppTextStyles.money.colored(AppColors.primaryDark)),
            ],
          ),
          const Gap(AppSpacing.sm),
          IconText(
            icon: Icons.calendar_today_outlined,
            text: '${Fmt.weekdayDate(booking.tourDate)} · ${TourBookingStrings.guests(booking.guests)}'
                '${booking.tourDeparture == null ? '' : ' · ${booking.tourDeparture}'}',
          ),
          if (booking.withRooms) ...[
            const Gap(4),
            IconText(
              icon: Icons.bed_outlined,
              text: 'Phòng ${booking.roomNumbers}'
                  '${booking.stayCheckout == null ? '' : ' · trả phòng ${Fmt.dayMonth(booking.stayCheckout)}'}',
            ),
          ],
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge.tourBooking(booking.status, dense: true),
              if (booking.createdByAi) const SoftTag(label: AiStrings.assistantName, icon: Icons.auto_awesome_rounded),
            ],
          ),
        ],
      ),
    );
  }
}
