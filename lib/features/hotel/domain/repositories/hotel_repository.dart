import '../../../../core/network/paged.dart';
import '../../../../core/network/upload_file.dart';
import '../../data/models/hotel_models.dart';
import '../entities/hotel.dart';

abstract interface class HotelRepository {
  Future<Paged<Hotel>> getHotels({required int page, required int size});

  /// Gom mọi trang của `/hotels`.
  Future<List<Hotel>> getAllHotels();

  Future<List<Hotel>> searchAvailable({
    required DateTime checkin,
    required DateTime checkout,
  });

  Future<List<Hotel>> byCategory(String category);

  Future<HotelDetail> getDetail(int id, {DateTime? checkin, DateTime? checkout});

  Future<Hotel> create(
    HotelCreateRequest request, {
    List<UploadFile> images = const [],
  });

  Future<Hotel> update(int id, HotelUpdateRequest request);

  Future<void> delete(int id);

  Future<List<String>> uploadImages(int id, List<UploadFile> images);
}
