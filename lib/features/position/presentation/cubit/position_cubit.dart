import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/position/data/mapper/position_mapper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/position.dart';
import '../../domain/usecases/get_positions.dart';
import '../../domain/usecases/create_position.dart';
import '../../domain/usecases/update_position.dart';
import '../../domain/usecases/delete_position.dart';

part 'position_state.dart';
part 'position_cubit.freezed.dart';

class PositionCubit extends Cubit<PositionState> {
  final GetPositions getPositions;
  final CreatePosition createPosition;
  final UpdatePosition updatePosition;
  final DeletePosition deletePosition;

  PositionCubit({
    required this.getPositions,
    required this.createPosition,
    required this.updatePosition,
    required this.deletePosition,
  }) : super(PositionState());

  Future<void> fetchPositions() async {
    try {
      emit(state.copyWith(status: PositionStatus.loading));
      final List<Position> positions = await getPositions.call();
      emit(
          state.copyWith(status: PositionStatus.success, positions: positions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> addPosition(Position position) async {
    try {
      emit(state.copyWith(status: PositionStatus.loading));
      var positionRes =
          await createPosition.call(PositionMapper.toCreate(position));
      var positions = state.positions?.toList() ?? [];
      positions.add(positionRes);
      emit(
          state.copyWith(status: PositionStatus.success, positions: positions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> editPosition(Position position) async {
    try {
      emit(state.copyWith(status: PositionStatus.loading));
      var positionRes =
          await updatePosition.call(PositionMapper.toUpdate(position));
      var positions = state.positions?.map((pos) {
        if (pos.id == positionRes.id) {
          pos = positionRes;
          return pos;
        }
        return pos;
      }).toList();
      emit(
          state.copyWith(status: PositionStatus.success, positions: positions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> removePosition(int id) async {
    try {
      emit(state.copyWith(status: PositionStatus.loading));

      await deletePosition.call(id);
      var positions = state.positions?.toList();
      positions?.removeWhere((position) => position.id == id);
      emit(
          state.copyWith(status: PositionStatus.success, positions: positions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
