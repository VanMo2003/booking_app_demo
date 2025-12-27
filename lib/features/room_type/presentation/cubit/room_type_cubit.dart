import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/room_type.dart';
import '../../domain/usecases/get_room_types.dart';
import '../../domain/usecases/create_room_type.dart';
import '../../domain/usecases/update_room_type.dart';
import '../../domain/usecases/delete_room_type.dart';

part 'room_type_state.dart';
part 'room_type_cubit.freezed.dart';

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
  }) : super(const RoomTypeState());

  Future<void> fetch() async {
    try {
      emit(state.copyWith(status: RoomTypeStatus.loading));
      final items = await getRoomTypes.call();
      emit(state.copyWith(status: RoomTypeStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> add(RoomType roomType) async {
    try {
      emit(state.copyWith(status: RoomTypeStatus.loading));
      final created = await createRoomType.call(roomType); // returns RoomType
      final List<RoomType> current = state.items?.toList() ?? [];
      current.add(created);
      emit(state.copyWith(status: RoomTypeStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> edit(RoomType roomType) async {
    try {
      emit(state.copyWith(status: RoomTypeStatus.loading));
      final updated = await updateRoomType.call(roomType);
      final List<RoomType>? current = state.items?.map((rt) {
        if (rt.id == updated.id) return updated;
        return rt;
      }).toList();
      emit(state.copyWith(status: RoomTypeStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> remove(int id) async {
    try {
      emit(state.copyWith(status: RoomTypeStatus.loading));
      await deleteRoomType.call(id);
      final List<RoomType>? current = state.items?.toList();
      current?.removeWhere((rt) => rt.id == id);
      emit(state.copyWith(status: RoomTypeStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
