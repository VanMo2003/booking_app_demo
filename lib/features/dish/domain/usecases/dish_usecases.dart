import 'package:injectable/injectable.dart';

import '../../../../core/network/upload_file.dart';
import '../../data/models/dish_models.dart';
import '../entities/dish.dart';
import '../repositories/dish_repository.dart';

@injectable
class GetBranchDishes {
  const GetBranchDishes(this._repository);

  final DishRepository _repository;

  Future<List<Dish>> call(int hotelId) => _repository.byHotel(hotelId);
}

@injectable
class SaveDish {
  const SaveDish(this._repository);

  final DishRepository _repository;

  /// [id] rỗng → tạo mới. Có [image] thì tải ảnh lên sau khi lưu món.
  Future<Dish> call(DishRequest request, {int? id, UploadFile? image}) async {
    final dish =
        id == null ? await _repository.create(request) : await _repository.update(id, request);
    return image == null ? dish : _repository.uploadImage(dish.id, image);
  }
}

@injectable
class SetDishAvailable {
  const SetDishAvailable(this._repository);

  final DishRepository _repository;

  Future<Dish> call(int id, bool available) => _repository.setAvailable(id, available);
}

@injectable
class DeleteDish {
  const DeleteDish(this._repository);

  final DishRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
