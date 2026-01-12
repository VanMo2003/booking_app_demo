import 'package:equatable/equatable.dart';

import '../../../domain/entity/room.dart';

enum RoomDetailStatus { initial, loading, success, failure }

class RoomDetailState extends Equatable {
  final RoomDetailStatus status;
  final Room? room;
  final String? errorMessage;
  final bool isUploadingImages;
  final String? uploadErrorMessage;

  const RoomDetailState({
    required this.status,
    this.room,
    this.errorMessage,
    this.isUploadingImages = false,
    this.uploadErrorMessage,
  });

  factory RoomDetailState.initial() => const RoomDetailState(
        status: RoomDetailStatus.initial,
      );

  RoomDetailState copyWith({
    RoomDetailStatus? status,
    Room? room,
    String? errorMessage,
    bool? isUploadingImages,
    String? uploadErrorMessage,
  }) {
    return RoomDetailState(
      status: status ?? this.status,
      room: room ?? this.room,
      errorMessage: errorMessage,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      uploadErrorMessage: uploadErrorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, room, errorMessage, isUploadingImages, uploadErrorMessage];
}
