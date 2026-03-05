import '../../../share/data/models/paged.dart';
import '../entities/hotel.dart';

abstract class HotelRepository {
  Future<Paged<Hotel>> getHotels({
    required int page,
    required int size,
    required String checkinDate,
    required String checkoutDate,
  });
  Future<Paged<Hotel>> getAllHotels({
    required int page,
    required int size,
  });
  Future<Hotel> createHotel({
    required String name,
    required String address,
    required String phone,
    required String description,
    required String category,
    required bool active,
    String? pathImage,
    required List<String> imagePaths,
  });
  Future<Hotel> getHotelById({
    required int id,
    String? checkinDate,
    String? checkoutDate,
  });
  Future<List<String>> uploadHotelImages(
      {required int hotelId, required List<String> filePaths});
}
