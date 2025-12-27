// import '../../domain/entity/position.dart';

// abstract class PositionState {}

// class PositionInitial extends PositionState {}

// class PositionLoading extends PositionState {}

// class PositionLoaded extends PositionState {
//   final List<Position> positions;

//   PositionLoaded(this.positions);
// }

// class PositionError extends PositionState {
//   final String message;

//   PositionError(this.message);
// }

part of "position_cubit.dart";

enum PositionStatus { initial, loading, success, failure }

extension PositionStatusX on PositionStatus {
  bool get isLoading => this == PositionStatus.loading;

  bool get isSuccess => this == PositionStatus.success;

  bool get isFailure => this == PositionStatus.failure;

  bool get isInitial => this == PositionStatus.initial;
}

@freezed
class PositionState with _$PositionState {
  const factory PositionState({
    @Default(PositionStatus.initial) PositionStatus status,
    List<Position>? positions,
    String? errorMessage,
  }) = _Initial;
}
