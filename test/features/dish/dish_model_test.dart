import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/features/dish/data/models/dish_models.dart';
import 'package:booking_app_mobile/features/dish/domain/entities/dish.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DishModel', () {
    test('đọc món từ DishResponse', () {
      final dish = DishModel.fromJson({
        'id': 12,
        'name': 'Phở bò tái',
        'description': 'Bánh phở tươi, nước dùng hầm xương 12 tiếng',
        'price': 85000.00,
        'category': 'MAIN_COURSE',
        'pathImage': 'https://images.unsplash.com/photo-1?w=1200',
        'available': false,
        'hotelId': 6,
      });
      expect(dish.category, DishCategory.mainCourse);
      expect(dish.price, 85000);
      expect(dish.available, isFalse);
      expect(dish.hotelId, 6);
    });

    test('thiếu trường tuỳ chọn: còn phục vụ, không ảnh, nhóm lạ thành Khác', () {
      final dish = DishModel.fromJson({
        'id': 1,
        'name': 'Trà đá',
        'price': '5000',
        'category': 'BREAKFAST',
        'hotelId': 6,
      });
      expect(dish.available, isTrue);
      expect(dish.pathImage, isNull);
      expect(dish.category, DishCategory.other);
    });
  });

  group('DishRequest', () {
    test('tạo mới gửi hotelId, sửa thì không; chuỗi ảnh rỗng để gỡ ảnh', () {
      const create = DishRequest(
        name: 'Chè khúc bạch',
        price: 45000.4,
        category: DishCategory.dessert,
        hotelId: 6,
      );
      expect(create.toJson(), {
        'name': 'Chè khúc bạch',
        'price': 45000,
        'category': 'DESSERT',
        'description': '',
        'available': true,
        'hotelId': 6,
      });
      const update = DishRequest(
        name: 'Chè khúc bạch',
        price: 45000,
        category: DishCategory.dessert,
        pathImage: '',
      );
      expect(update.toJson().containsKey('hotelId'), isFalse);
      expect(update.toJson()['pathImage'], '');
    });
  });

  test('byCategory gom theo thứ tự thực đơn và bỏ nhóm rỗng', () {
    Dish dish(int id, DishCategory category) =>
        Dish(id: id, name: '#$id', price: 1, category: category, hotelId: 1);
    final groups = [
      dish(1, DishCategory.drink),
      dish(2, DishCategory.appetizer),
      dish(3, DishCategory.drink),
    ].byCategory();
    expect(groups.keys, [DishCategory.appetizer, DishCategory.drink]);
    expect(groups[DishCategory.drink]!.map((d) => d.id), [1, 3]);
  });
}
