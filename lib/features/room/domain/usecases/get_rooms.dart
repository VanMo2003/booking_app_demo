import 'package:injectable/injectable.dart';

import '../repositories/room_repository.dart';

@injectable
class GetAvailableRooms {
  final RoomRepository repository;

  GetAvailableRooms(this.repository);

  Future<RoomList> call({
    required int hotelId,
    required String checkinDate,
    required String checkoutDate,
  }) async {
    final items = await repository.getAvailableRooms(
      hotelId: hotelId,
      checkinDate: checkinDate,
      checkoutDate: checkoutDate,
    );
    return RoomList(
      content: items,
      page: 0,
      size: items.length,
      totalElements: items.length,
      totalPages: 1,
    );
  }
}
