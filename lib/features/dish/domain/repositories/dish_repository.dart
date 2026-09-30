import '../../../../core/network/upload_file.dart';
import '../../data/models/dish_models.dart';
import '../entities/dish.dart';

abstract interface class DishRepository {
  Future<List<Dish>> byHotel(int hotelId);

  Future<Dish> create(DishRequest request);

  Future<Dish> update(int id, DishRequest request);

  /// Chỉ đổi trạng thái phục vụ (sửa một phần).
  Future<Dish> setAvailable(int id, bool available);

  Future<Dish> uploadImage(int id, UploadFile image);

  Future<void> delete(int id);
}
