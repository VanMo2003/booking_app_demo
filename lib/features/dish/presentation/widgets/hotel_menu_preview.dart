import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/menu_strings.dart';
import '../../domain/entities/dish.dart';
import '../../domain/usecases/dish_usecases.dart';
import 'dish_tile.dart';

/// Mục "Thực đơn" ở trang chi tiết cơ sở: vài món tiêu biểu + nút xem đủ.
/// Thực đơn là phần phụ nên đang tải, lỗi hay chưa có món thì ẩn hẳn — không
/// chen trạng thái lỗi vào giữa trang đặt phòng.
class HotelMenuPreview extends StatefulWidget {
  const HotelMenuPreview({super.key, required this.hotelId, this.hotelName});

  static const _previewCount = 8;

  final int hotelId;
  final String? hotelName;

  @override
  State<HotelMenuPreview> createState() => _HotelMenuPreviewState();
}

class _HotelMenuPreviewState extends State<HotelMenuPreview> {
  late final Future<List<Dish>> _dishes = getIt<GetBranchDishes>()(widget.hotelId);

  void _openMenu() => context.router.push(
        HotelMenuRoute(hotelId: widget.hotelId, hotelName: widget.hotelName),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dish>>(
      future: _dishes,
      builder: (context, snapshot) {
        final dishes = snapshot.data ?? const <Dish>[];
        if (dishes.isEmpty) return const SizedBox.shrink();
        // Món đang phục vụ lên trước; thứ tự nhóm giữ như thực đơn.
        final preview = [
          ...dishes.where((dish) => dish.available),
          ...dishes.where((dish) => !dish.available),
        ].take(HotelMenuPreview._previewCount).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(AppSpacing.xl),
            SectionHeader(
              title: MenuStrings.title,
              subtitle: MenuStrings.dishesCount(dishes.length),
              actionLabel: MenuStrings.viewMenu,
              onAction: _openMenu,
            ),
            const Gap(AppSpacing.sm),
            SizedBox(
              height: 162,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: preview.length,
                separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                itemBuilder: (context, index) =>
                    DishPreviewCard(dish: preview[index], onTap: _openMenu),
              ),
            ),
          ],
        );
      },
    );
  }
}
