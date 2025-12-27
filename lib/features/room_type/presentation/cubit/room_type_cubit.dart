import 'package:bloc/bloc.dart';

import '../../domain/entity/room_type.dart';
import '../../domain/usecases/get_room_types.dart';
import '../../domain/usecases/create_room_type.dart';
import '../../domain/usecases/update_room_type.dart';
import '../../domain/usecases/delete_room_type.dart';
import 'room_type_state.dart';

class RoomTypeCubit extends Cubit<RoomTypeState> {
  final GetRoomTypes getRoomTypes;
  final CreateRoomType createRoomType;
  final UpdateRoomType updateRoomType;
  final DeleteRoomType deleteRoomType;

  RoomTypeCubit({
    required this.getRoomTypes,
    required this.createRoomType,
    required this.updateRoomType,
    required this.deleteRoomType,
  }) : super(RoomTypeInitial());

  Future<void> fetch() async {
    try {
      emit(RoomTypeLoading());
      final items = await getRoomTypes.call();
      emit(RoomTypeLoaded(items));
    } catch (e) {
      emit(RoomTypeError(e.toString()));
    }
  }

  Future<void> add(RoomType roomType) async {
    try {
      emit(RoomTypeLoading());
      await createRoomType.call(roomType);
      await fetch();
    } catch (e) {
      emit(RoomTypeError(e.toString()));
    }
  }

  Future<void> edit(RoomType roomType) async {
    try {
      emit(RoomTypeLoading());
      await updateRoomType.call(roomType);
      await fetch();
    } catch (e) {
      emit(RoomTypeError(e.toString()));
    }
  }

  Future<void> remove(int id) async {
    try {
      emit(RoomTypeLoading());
      await deleteRoomType.call(id);
      await fetch();
    } catch (e) {
      emit(RoomTypeError(e.toString()));
    }
  }
}
