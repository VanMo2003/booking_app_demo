import '../../../../core/network/paged.dart';
import '../entities/travel_theme.dart';
import '../../../../core/network/upload_file.dart';
import '../../data/models/tour_models.dart';
import '../entities/tour.dart';

abstract interface class TourRepository {
  /// Kỳ ở kèm tour từ ngày [date] và các phòng của gói còn trống.
  Future<TourStay> availableRooms(int tourId, DateTime date);

  /// Tour đang nhận khách trước, rẻ trước.
  Future<List<Tour>> byHotel(int hotelId);

  Future<Tour> byId(int id);

  /// Tìm tour ở mọi cơ sở (nổi bật trước, mới trước).
  Future<Paged<Tour>> search({String? query, TravelTheme? theme, double? maxPrice, int page = 0});

  Future<List<TourDestination>> destinations();

  /// Trang chủ; [interests] rỗng thì không có mục gợi ý.
  Future<TourHome> home(List<TravelTheme> interests);

  Future<Tour> create(TourRequest request);

  Future<Tour> update(int id, TourRequest request);

  /// Chỉ đổi trạng thái nhận khách (sửa một phần).
  Future<Tour> setAvailable(int id, bool available);

  Future<Tour> uploadImage(int id, UploadFile image);

  Future<void> delete(int id);
}
