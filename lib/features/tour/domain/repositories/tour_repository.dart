import '../../../../core/network/upload_file.dart';
import '../../data/models/tour_models.dart';
import '../entities/tour.dart';

abstract interface class TourRepository {
  /// Kỳ ở kèm tour từ ngày [date] và các phòng của gói còn trống.
  Future<TourStay> availableRooms(int tourId, DateTime date);

  /// Tour đang nhận khách trước, rẻ trước.
  Future<List<Tour>> byHotel(int hotelId);

  Future<Tour> create(TourRequest request);

  Future<Tour> update(int id, TourRequest request);

  /// Chỉ đổi trạng thái nhận khách (sửa một phần).
  Future<Tour> setAvailable(int id, bool available);

  Future<Tour> uploadImage(int id, UploadFile image);

  Future<void> delete(int id);
}
