import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../favorite/domain/entities/favorite_hotel.dart';
import '../../../favorite/presentation/favorite_button.dart';
import '../../domain/entities/hotel.dart';

FavoriteHotel favoriteOf(Hotel hotel) => FavoriteHotel(
      id: hotel.id,
      name: hotel.name,
      address: hotel.address,
      category: hotel.category,
      rating: hotel.rating,
      pathImage: hotel.pathImage,
    );

/// Thẻ cơ sở trong danh sách khám phá / kết quả tìm kiếm.
class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.showAvailability = false,
  });

  final Hotel hotel;
  final VoidCallback onTap;

  /// Hiện trạng thái Còn phòng / Hết phòng / Tạm đóng (khi tìm theo ngày).
  final bool showAvailability;

  @override
  Widget build(BuildContext context) {
    final dimmed = showAvailability && !hotel.acceptsBooking;
    final amenities = hotel.amenities.where((a) => a.common).toList();
    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(path: hotel.pathImage),
                  if (hotel.category.isNotEmpty)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(hotel.category, style: AppTextStyles.captionStrong),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: FavoriteButton(hotel: favoriteOf(hotel)),
                  ),
                  if (showAvailability && hotel.status != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: StatusBadge.hotel(hotel.status!),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hotel.rating > 0) ...[
                        const Gap(AppSpacing.xs),
                        const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
                        const Gap(2),
                        Text('${hotel.rating}', style: AppTextStyles.bodyStrong),
                      ],
                    ],
                  ),
                  const Gap(4),
                  IconText(icon: Icons.location_on_outlined, text: hotel.address),
                  if (amenities.isNotEmpty) ...[
                    const Gap(10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final amenity in amenities.take(3))
                          SoftTag(label: amenity.name, tone: StatusTone.brand),
                        if (amenities.length > 3)
                          SoftTag(label: '+${amenities.length - 3}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
