import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:injectable/injectable.dart';

import '../../../share/data/models/paged.dart';

@injectable
class GetHotelUseCase {
  final HotelRepository repository;

  GetHotelUseCase(this.repository);

  Future<Paged<Hotel>> call({required int page, required int size}) async {
    return await repository.getHotels(page: page, size: size);
  }
}
