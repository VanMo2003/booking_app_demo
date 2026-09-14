import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import 'payment_countdown.dart';

enum BookingCardView {
  /// Khách xem: nổi bật cơ sở.
  customer,

  /// Lễ tân xem: nổi bật khách.
  desk,
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.view = BookingCardView.customer,
  });

  final Booking booking;
  final VoidCallback onTap;
  final BookingCardView view;

  @override
  Widget build(BuildContext context) {
    final forCustomer = view == BookingCardView.customer;
    final title = forCustomer
        ? booking.hotel?.name ?? BookingStrings.branch
        : booking.customer?.fullName ?? BookingStrings.walkInGuest;
    final subtitle = forCustomer
        ? BookingStrings.code(booking.id)
        : '${BookingStrings.code(booking.id)} · ${booking.customer?.phoneNumber ?? ''}';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (forCustomer)
                AppNetworkImage(
                  path: booking.hotel?.pathImage,
                  width: 52,
                  height: 52,
                  borderRadius: AppRadius.smAll,
                )
              else
                AppAvatar(name: booking.customer?.fullName, size: 44),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                Fmt.money(booking.totalAmount),
                style: AppTextStyles.money.colored(AppColors.primaryDark),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          IconText(
            icon: Icons.calendar_today_outlined,
            text:
                '${Fmt.weekdayDate(booking.checkinDate)} → ${Fmt.weekdayDate(booking.checkoutDate)} · ${AppStrings.nights(booking.nights)}',
          ),
          if (booking.rooms.isNotEmpty) ...[
            const Gap(4),
            IconText(
              icon: Icons.bed_outlined,
              text: '${booking.rooms.length} phòng: ${booking.roomNumbers}',
            ),
          ],
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge.booking(booking.status, dense: true),
              StatusBadge.payment(booking.paymentStatus, dense: true),
              if (!forCustomer && booking.createdAtDesk)
                const SoftTag(label: BookingStrings.createdAtDesk),
            ],
          ),
          if (forCustomer && booking.canPayOnline && booking.paymentExpireAt != null) ...[
            const Gap(AppSpacing.xs),
            PaymentCountdown(expireAt: booking.paymentExpireAt!, compact: true),
          ],
        ],
      ),
    );
  }
}
