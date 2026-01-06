import '../../../share/data/models/paged.dart';
import '../entities/hotel.dart';

abstract class HotelRepository {
  Future<Paged<Hotel>> getHotels({required int page, required int size});
}
