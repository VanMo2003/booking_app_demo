import 'package:injectable/injectable.dart';

import '../../../../core/network/upload_file.dart';
import '../../domain/entities/dish.dart';
import '../../domain/repositories/dish_repository.dart';
import '../datasources/dish_api.dart';
import '../models/dish_models.dart';

@LazySingleton(as: DishRepository)
class DishRepositoryImpl implements DishRepository {
  DishRepositoryImpl(this._api);

  final DishApi _api;

  @override
  Future<List<Dish>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(DishModel.fromJson);

  @override
  Future<Dish> create(DishRequest request) async =>
      (await _api.create(request.toJson())).parse(DishModel.fromJson);

  @override
  Future<Dish> update(int id, DishRequest request) async =>
      (await _api.update(id, request.toJson())).parse(DishModel.fromJson);

  @override
  Future<Dish> setAvailable(int id, bool available) async =>
      (await _api.update(id, {'available': available})).parse(DishModel.fromJson);

  @override
  Future<Dish> uploadImage(int id, UploadFile image) async =>
      (await _api.uploadImage(id, [image.toMultipart()])).parse(DishModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
