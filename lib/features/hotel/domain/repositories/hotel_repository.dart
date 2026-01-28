import '../../../share/data/models/paged.dart';
import '../entities/hotel.dart';

abstract class HotelRepository {
  Future<Paged<Hotel>> getHotels({
    required int page,
    required int size,
    required String checkinDate,
    required String checkoutDate,
  });
  Future<Hotel> getHotelById({required int id});
  Future<List<String>> uploadHotelImages(
      {required int hotelId, required List<String> filePaths});
}
