import 'package:bloc/bloc.dart';

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
}
