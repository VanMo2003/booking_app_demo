import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../domain/entities/room.dart';

/// Dòng phòng: ảnh vuông, tên + loại, sức chứa, giá/đêm, trạng thái.
class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.room,
    this.onTap,
    this.showStatus = true,
    this.trailing,
  });

  final Room room;
  final VoidCallback? onTap;
  final bool showStatus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppNetworkImage(
            path: room.pathImage,
            width: 84,
            height: 84,
            borderRadius: AppRadius.smAll,
            placeholderIcon: Icons.bed_rounded,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                IconText(
                  icon: Icons.people_alt_outlined,
                  text: AppStrings.guests(room.capacity),
                ),
                const Gap(6),
                Row(
                  children: [
                    Expanded(child: PriceText(room.price, unit: AppStrings.perNight)),
                    if (showStatus) StatusBadge.room(room.status, dense: true),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const Gap(AppSpacing.xs), trailing!],
        ],
      ),
    );
  }
}
