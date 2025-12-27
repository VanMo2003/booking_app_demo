import '../../domain/entity/position.dart';

abstract class PositionState {}

class PositionInitial extends PositionState {}

class PositionLoading extends PositionState {}

class PositionLoaded extends PositionState {
  final List<Position> positions;

  PositionLoaded(this.positions);
}

class PositionError extends PositionState {
  final String message;

  PositionError(this.message);
}
