import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/position/data/mapper/position_mapper.dart';

import '../../domain/entity/position.dart';
import '../../domain/usecases/get_positions.dart';
import '../../domain/usecases/create_position.dart';
import '../../domain/usecases/update_position.dart';
import '../../domain/usecases/delete_position.dart';
import 'position_state.dart';

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
  }) : super(PositionInitial());

  Future<void> fetchPositions() async {
    try {
      emit(PositionLoading());
      final List<Position> positions = await getPositions.call();
      emit(PositionLoaded(positions));
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }

  Future<void> addPosition(Position position) async {
    try {
      emit(PositionLoading());
      await createPosition.call(PositionMapper.toCreate(position));
      await fetchPositions();
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }

  Future<void> editPosition(Position position) async {
    try {
      emit(PositionLoading());
      await updatePosition.call(PositionMapper.toUpdate(position));
      await fetchPositions();
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }

  Future<void> removePosition(int id) async {
    try {
      emit(PositionLoading());
      await deletePosition.call(id);
      await fetchPositions();
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }
}
