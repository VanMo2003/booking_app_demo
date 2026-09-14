import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/paged.dart';
import '../../../../core/network/upload_file.dart';
import '../../data/models/hotel_models.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

@injectable
class GetHotelsPage {
  const GetHotelsPage(this._repository);

  final HotelRepository _repository;

  Future<Paged<Hotel>> call(int page) =>
      _repository.getHotels(page: page, size: AppConstants.pageSize);
}

@injectable
class GetAllHotels {
  const GetAllHotels(this._repository);

  final HotelRepository _repository;

  Future<List<Hotel>> call() => _repository.getAllHotels();
}

@injectable
class GetHotelsByCategory {
  const GetHotelsByCategory(this._repository);

  final HotelRepository _repository;

  Future<List<Hotel>> call(String category) => _repository.byCategory(category);
}

/// Tìm cơ sở theo ngày; cơ sở còn phòng xếp lên trước.
@injectable
class SearchAvailableHotels {
  const SearchAvailableHotels(this._repository);

  final HotelRepository _repository;

  Future<List<Hotel>> call({
    required DateTime checkin,
    required DateTime checkout,
  }) async {
    final hotels = await _repository.searchAvailable(
      checkin: checkin,
      checkout: checkout,
    );
    return [...hotels]
      ..sort((a, b) {
        final rankA = a.acceptsBooking ? 0 : 1;
        final rankB = b.acceptsBooking ? 0 : 1;
        return rankA != rankB ? rankA - rankB : b.rating - a.rating;
      });
  }
}

@injectable
class GetHotelDetail {
  const GetHotelDetail(this._repository);

  final HotelRepository _repository;

  Future<HotelDetail> call(int id, {DateTime? checkin, DateTime? checkout}) =>
      _repository.getDetail(id, checkin: checkin, checkout: checkout);
}

/// Các cơ sở đang giao cho một tài khoản quản lý (lọc từ `/hotels` công khai).
@injectable
class GetManagedHotels {
  const GetManagedHotels(this._repository);

  final HotelRepository _repository;

  Future<List<Hotel>> call(String managerAccountId) async =>
      (await _repository.getAllHotels())
          .where((hotel) => hotel.accountId == managerAccountId)
          .toList();
}

@injectable
class CreateBranch {
  const CreateBranch(this._repository);

  final HotelRepository _repository;

  Future<Hotel> call(HotelCreateRequest request, List<UploadFile> images) =>
      _repository.create(request, images: images);
}

@injectable
class UpdateBranch {
  const UpdateBranch(this._repository);

  final HotelRepository _repository;

  Future<Hotel> call(int id, HotelUpdateRequest request) =>
      _repository.update(id, request);
}

/// Mở/đóng nhận khách: BE cần đủ trường nên đọc chi tiết trước rồi mới cập nhật.
@injectable
class SetBranchActive {
  const SetBranchActive(this._repository);

  final HotelRepository _repository;

  Future<Hotel> call(int id, {required bool active}) async {
    final detail = await _repository.getDetail(id);
    return _repository.update(
      id,
      HotelUpdateRequest.fromHotel(detail.hotel, active: active),
    );
  }
}

@injectable
class DeleteBranch {
  const DeleteBranch(this._repository);

  final HotelRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}

@injectable
class UploadBranchImages {
  const UploadBranchImages(this._repository);

  final HotelRepository _repository;

  Future<List<String>> call(int id, List<UploadFile> images) =>
      _repository.uploadImages(id, images);
}
