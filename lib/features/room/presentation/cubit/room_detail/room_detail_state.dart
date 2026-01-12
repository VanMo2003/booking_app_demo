import 'package:equatable/equatable.dart';

import '../../../domain/entity/room.dart';

enum RoomDetailStatus { initial, loading, success, failure }

class RoomDetailState extends Equatable {
  final RoomDetailStatus status;
  final Room? room;
  final String? errorMessage;

  const RoomDetailState({
    required this.status,
    this.room,
    this.errorMessage,
  });

  factory RoomDetailState.initial() => const RoomDetailState(
        status: RoomDetailStatus.initial,
      );

  RoomDetailState copyWith({
    RoomDetailStatus? status,
    Room? room,
    String? errorMessage,
  }) {
    return RoomDetailState(
      status: status ?? this.status,
      room: room ?? this.room,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, room, errorMessage];
}
