import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

/// Món trên thực đơn của một cơ sở.
class Dish extends Equatable {
  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.hotelId,
    this.description = '',
    this.pathImage,
    this.available = true,
  });

  final int id;
  final String name;
  final double price;
  final DishCategory category;
  final int hotelId;
  final String description;
  final String? pathImage;

  /// `false` = bếp tạm hết; món vẫn nằm trên thực đơn, hiện mờ.
  final bool available;

  @override
  List<Object?> get props =>
      [id, name, price, category, hotelId, description, pathImage, available];
}

extension DishMenuX on List<Dish> {
  /// Gom theo nhóm, giữ thứ tự đọc thực đơn (Khai vị → … → Khác); bỏ nhóm rỗng.
  Map<DishCategory, List<Dish>> byCategory() => {
        for (final category in DishCategory.values)
          if (any((dish) => dish.category == category))
            category: where((dish) => dish.category == category).toList(),
      };
}
