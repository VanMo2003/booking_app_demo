import 'package:injectable/injectable.dart';

import '../../data/models/hotel_service_models.dart';
import '../entities/hotel_service.dart';
import '../repositories/hotel_service_repository.dart';

@injectable
class GetBranchServices {
  const GetBranchServices(this._repository);

  final HotelServiceRepository _repository;

  Future<List<HotelService>> call(int hotelId) => _repository.byHotel(hotelId);
}

@injectable
class SaveService {
  const SaveService(this._repository);

  final HotelServiceRepository _repository;

  /// [id] rỗng → tạo mới.
  Future<HotelService> call(ServiceRequest request, {int? id}) =>
      id == null ? _repository.create(request) : _repository.update(id, request);
}

@injectable
class DeleteService {
  const DeleteService(this._repository);

  final HotelServiceRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
