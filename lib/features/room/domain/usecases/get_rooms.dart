import 'package:injectable/injectable.dart';

import '../repositories/room_repository.dart';

@injectable
class GetRooms {
  final RoomRepository repository;

  GetRooms(this.repository);

  Future<RoomList> call(
      {required int hotelId, int page = 0, int size = 10}) async {
    return await repository.getRooms(hotelId: hotelId, page: page, size: size);
  }
}
