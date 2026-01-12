import 'package:bloc/bloc.dart';

import '../../../domain/entity/room.dart';
import '../../../domain/repositories/room_repository.dart';
import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  final RoomRepository repository;

  RoomDetailCubit(this.repository) : super(RoomDetailState.initial());

  Future<void> fetch(int id) async {
    emit(state.copyWith(status: RoomDetailStatus.loading, errorMessage: null));
    try {
      final room = await repository.getRoomById(id: id);
      emit(state.copyWith(status: RoomDetailStatus.success, room: room));
    } catch (e) {
      emit(state.copyWith(
        status: RoomDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> uploadImages(
      {required int roomId, required List<String> filePaths}) async {
    if (filePaths.isEmpty) return false;
    emit(state.copyWith(isUploadingImages: true, uploadErrorMessage: null));
    try {
      final uploaded = await repository.uploadRoomImages(
        roomId: roomId,
        filePaths: filePaths,
      );
      final updatedRoom = _mergeRoomImages(state.room, uploaded);
      emit(state.copyWith(
        isUploadingImages: false,
        room: updatedRoom ?? state.room,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUploadingImages: false,
        uploadErrorMessage: e.toString(),
      ));
      return false;
    }
  }

  Room? _mergeRoomImages(Room? room, List<String> newImages) {
    if (room == null) return null;
    final existing = room.images ?? [];
    final merged = [...existing, ...newImages];
    return Room(
      id: room.id,
      pathImage: room.pathImage,
      roomNumber: room.roomNumber,
      price: room.price,
      description: room.description,
      capacity: room.capacity,
      status: room.status,
      hotelId: room.hotelId,
      hotelName: room.hotelName,
      roomTypeId: room.roomTypeId,
      roomTypeName: room.roomTypeName,
      onCreate: room.onCreate,
      onUpdate: room.onUpdate,
      images: merged,
      amenities: room.amenities,
    );
  }
}
