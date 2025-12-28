import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entity/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/usecases/get_rooms.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/update_room.dart';
import '../../domain/usecases/delete_room.dart';

part 'room_state.dart';
part 'room_cubit.freezed.dart';

class RoomCubit extends Cubit<RoomState> {
  final GetRooms getRooms;
  final CreateRoom createRoom;
  final UpdateRoom updateRoom;
  final DeleteRoom deleteRoom;

  RoomCubit({
    required this.getRooms,
    required this.createRoom,
    required this.updateRoom,
    required this.deleteRoom,
  }) : super(const RoomState());

  Future<void> fetch(
      {required int hotelId, int page = 0, int size = 10}) async {
    try {
      emit(state.copyWith(status: RoomStatus.loading));
      final data =
          await getRooms.call(hotelId: hotelId, page: page, size: size);
      emit(state.copyWith(status: RoomStatus.success, data: data));
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  Future<void> add(Room room) async {
    try {
      emit(state.copyWith(status: RoomStatus.loading));
      final created = await createRoom.call(room);
      final rl = state.data ??
          (RoomList(
              content: [], page: 0, size: 10, totalElements: 0, totalPages: 1));
      final newContent = rl.content.toList();
      newContent.add(created);
      final newData = RoomList(
          content: newContent,
          page: rl.page,
          size: rl.size,
          totalElements: rl.totalElements + 1,
          totalPages: rl.totalPages);
      emit(state.copyWith(status: RoomStatus.success, data: newData));
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  Future<void> edit(Room room) async {
    try {
      emit(state.copyWith(status: RoomStatus.loading));
      final updated = await updateRoom.call(room);
      final rl = state.data;
      if (rl != null) {
        final newContent =
            rl.content.map((r) => r.id == updated.id ? updated : r).toList();
        final newData = RoomList(
            content: newContent,
            page: rl.page,
            size: rl.size,
            totalElements: rl.totalElements,
            totalPages: rl.totalPages);
        emit(state.copyWith(status: RoomStatus.success, data: newData));
      } else {
        emit(state.copyWith(status: RoomStatus.success));
      }
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  Future<void> remove(int id) async {
    try {
      emit(state.copyWith(status: RoomStatus.loading));
      await deleteRoom.call(id);
      final rl = state.data;
      if (rl != null) {
        final newContent = rl.content.where((r) => r.id != id).toList();
        final newData = RoomList(
            content: newContent,
            page: rl.page,
            size: rl.size,
            totalElements: rl.totalElements - 1,
            totalPages: rl.totalPages);
        emit(state.copyWith(status: RoomStatus.success, data: newData));
      } else {
        emit(state.copyWith(status: RoomStatus.success));
      }
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }
}
