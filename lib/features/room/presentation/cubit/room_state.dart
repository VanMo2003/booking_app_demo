part of "room_cubit.dart";

enum RoomStatus { initial, loading, success, failure }

extension RoomStatusX on RoomStatus {
  bool get isLoading => this == RoomStatus.loading;
  bool get isSuccess => this == RoomStatus.success;
  bool get isFailure => this == RoomStatus.failure;
  bool get isInitial => this == RoomStatus.initial;
}

@freezed
class RoomState with _$RoomState {
  const factory RoomState({
    @Default(RoomStatus.initial) RoomStatus status,
    RoomList? data,
    String? errorMessage,
  }) = _RoomState;
}
