part of "room_type_cubit.dart";

enum RoomTypeStatus { initial, loading, success, failure }

extension RoomTypeStatusX on RoomTypeStatus {
  bool get isLoading => this == RoomTypeStatus.loading;
  bool get isSuccess => this == RoomTypeStatus.success;
  bool get isFailure => this == RoomTypeStatus.failure;
  bool get isInitial => this == RoomTypeStatus.initial;
}

@freezed
class RoomTypeState with _$RoomTypeState {
  const factory RoomTypeState({
    @Default(RoomTypeStatus.initial) RoomTypeStatus status,
    List<RoomType>? items,
    String? errorMessage,
  }) = _RoomTypeState;
}
