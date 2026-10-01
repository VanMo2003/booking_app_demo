import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/tour_strings.dart';
import '../../domain/entities/tour.dart';
import '../../domain/usecases/tour_usecases.dart';
import '../tour_detail_screen.dart';

/// Mục "Tour tham quan" ở trang chi tiết cơ sở: vài tour đang nhận khách + nút xem tất cả.
/// Là phần phụ nên đang tải, lỗi hay chưa có tour thì ẩn hẳn.
class HotelToursSection extends StatefulWidget {
  const HotelToursSection({super.key, required this.hotelId, this.hotelName});

  static const _previewCount = 3;

  final int hotelId;
  final String? hotelName;

  @override
  State<HotelToursSection> createState() => _HotelToursSectionState();
}

class _HotelToursSectionState extends State<HotelToursSection> {
  late final Future<List<Tour>> _tours = getIt<GetBranchTours>()(widget.hotelId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tour>>(
      future: _tours,
      builder: (context, snapshot) {
        final tours = snapshot.data ?? const <Tour>[];
        if (tours.isEmpty) return const SizedBox.shrink();
        // BE đã xếp tour đang nhận khách lên trước.
        final preview = tours.take(HotelToursSection._previewCount).toList();
        final more = tours.length > preview.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(AppSpacing.xl),
            SectionHeader(
              title: TourStrings.title,
              subtitle: TourStrings.sectionSubtitle,
              actionLabel: more ? TourStrings.viewAll(tours.length) : null,
              onAction: more
                  ? () => context.router.push(HotelToursRoute(tours: tours, hotelName: widget.hotelName))
                  : null,
            ),
            const Gap(AppSpacing.sm),
            for (final tour in preview) ...[
              TourCardLink(tour: tour, hotelName: widget.hotelName),
              const Gap(AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}
