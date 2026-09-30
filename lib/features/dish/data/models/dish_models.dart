import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/dish.dart';

/// JSON `DishResponse` ↔ [Dish].
abstract final class DishModel {
  static Dish fromJson(Json json) => Dish(
        id: json.integer('id'),
        name: json.str('name'),
        price: json.decimal('price'),
        category: DishCategory.parse(json.strOrNull('category')),
        hotelId: json.integer('hotelId'),
        description: json.str('description'),
        pathImage: json.strOrNull('pathImage'),
        available: json.flag('available', true),
      );
}

class DishRequest {
  const DishRequest({
    required this.name,
    required this.price,
    required this.category,
    this.description = '',
    this.pathImage,
    this.available = true,
    this.hotelId,
  });

  final String name;
  final double price;
  final DishCategory category;
  final String description;

  /// Link ảnh dán tay; chuỗi rỗng khi sửa = gỡ ảnh. Ảnh chọn từ máy tải lên sau.
  final String? pathImage;
  final bool available;

  /// Chỉ cần khi tạo mới.
  final int? hotelId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price.round(),
        'category': category.value,
        'description': description,
        if (pathImage != null) 'pathImage': pathImage,
        'available': available,
        if (hotelId != null) 'hotelId': hotelId,
      };
}
