import 'package:injectable/injectable.dart';

import '../../../../core/network/upload_file.dart';
import '../../data/models/tour_models.dart';
import '../entities/tour.dart';
import '../repositories/tour_repository.dart';

@injectable
class GetBranchTours {
  const GetBranchTours(this._repository);

  final TourRepository _repository;

  Future<List<Tour>> call(int hotelId) => _repository.byHotel(hotelId);
}

/// Phòng của gói còn trống cho ngày đi tour.
@injectable
class GetTourStay {
  const GetTourStay(this._repository);

  final TourRepository _repository;

  Future<TourStay> call(int tourId, DateTime date) => _repository.availableRooms(tourId, date);
}

@injectable
class SaveTour {
  const SaveTour(this._repository);

  final TourRepository _repository;

  /// [id] rỗng → tạo mới. Có [image] thì tải ảnh lên sau khi lưu tour.
  Future<Tour> call(TourRequest request, {int? id, UploadFile? image}) async {
    final tour =
        id == null ? await _repository.create(request) : await _repository.update(id, request);
    return image == null ? tour : _repository.uploadImage(tour.id, image);
  }
}

@injectable
class SetTourAvailable {
  const SetTourAvailable(this._repository);

  final TourRepository _repository;

  Future<Tour> call(int id, bool available) => _repository.setAvailable(id, available);
}

@injectable
class DeleteTour {
  const DeleteTour(this._repository);

  final TourRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
