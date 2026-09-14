import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../room/domain/entities/room.dart';
import '../../../service/domain/entities/hotel_service.dart';

/// Các khối form dùng chung giữa Đặt phòng (khách) và Đặt tại quầy (lễ tân).

class BranchSummaryCard extends StatelessWidget {
  const BranchSummaryCard({super.key, required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppNetworkImage(
            path: hotel.pathImage,
            width: 56,
            height: 56,
            borderRadius: AppRadius.smAll,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                const Gap(2),
                IconText(icon: Icons.location_on_outlined, text: hotel.address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoomChoiceList extends StatelessWidget {
  const RoomChoiceList({
    super.key,
    required this.rooms,
    required this.selectedIds,
    required this.onToggle,
    this.keepIds = const {},
  });

  final List<Room> rooms;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  /// Phòng đang thuộc chính đơn đang sửa — BE báo BOOKED nhưng vẫn được giữ.
  final Set<int> keepIds;

  bool _enabled(Room room) => room.status.isBookable || keepIds.contains(room.id);

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Text(ExploreStrings.noRooms, style: AppTextStyles.bodySmall);
    }
    final hasAvailable = rooms.any(_enabled);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(BookingStrings.noRoomsForDates, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ),
        for (final room in rooms) ...[
          SelectableCard(
            selected: selectedIds.contains(room.id),
            enabled: _enabled(room),
            onTap: () => onToggle(room.id),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.title, style: AppTextStyles.bodyStrong),
                      const Gap(2),
                      Row(
                        children: [
                          Flexible(
                            child: IconText(
                              icon: Icons.people_alt_outlined,
                              text: AppStrings.guests(room.capacity),
                            ),
                          ),
                          if (!_enabled(room)) ...[
                            const Gap(AppSpacing.xs),
                            StatusBadge.room(room.status, dense: true),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PriceText(room.price, unit: AppStrings.perNight),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

class ServiceChoiceList extends StatelessWidget {
  const ServiceChoiceList({
    super.key,
    required this.services,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<HotelService> services;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(BookingStrings.noServices, style: AppTextStyles.bodySmall);
    }
    return Column(
      children: [
        for (final service in services) ...[
          SelectableCard(
            selected: selectedIds.contains(service.id),
            onTap: () => onToggle(service.id),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: AppTextStyles.bodyStrong),
                      if (service.description.isNotEmpty)
                        Text(service.description, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(Fmt.money(service.unitPrice), style: AppTextStyles.money),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.methods = PaymentMethod.values,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;
  final List<PaymentMethod> methods;

  static IconData iconOf(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.bankTransfer => Icons.account_balance_outlined,
        PaymentMethod.vnPay => Icons.qr_code_2_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final method in methods) ...[
          SelectableCard(
            multiple: false,
            selected: method == selected,
            onTap: () => onSelected(method),
            child: Row(
              children: [
                Icon(iconOf(method), color: AppColors.primary),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(method.label, style: AppTextStyles.bodyStrong),
                      Text(method.description, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}
