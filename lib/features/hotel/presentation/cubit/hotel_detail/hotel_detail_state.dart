import 'package:equatable/equatable.dart';

import '../../../domain/entities/hotel.dart';

enum HotelDetailStatus { initial, loading, success, failure }

class HotelDetailState extends Equatable {
  final HotelDetailStatus status;
  final Hotel? hotel;
  final String? errorMessage;
  final bool isUploadingImages;
  final String? uploadErrorMessage;

  const HotelDetailState({
    required this.status,
    this.hotel,
    this.errorMessage,
    this.isUploadingImages = false,
    this.uploadErrorMessage,
  });

  factory HotelDetailState.initial() => const HotelDetailState(
        status: HotelDetailStatus.initial,
      );

  HotelDetailState copyWith({
    HotelDetailStatus? status,
    Hotel? hotel,
    String? errorMessage,
    bool? isUploadingImages,
    String? uploadErrorMessage,
  }) {
    return HotelDetailState(
      status: status ?? this.status,
      hotel: hotel ?? this.hotel,
      errorMessage: errorMessage,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      uploadErrorMessage: uploadErrorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, hotel, errorMessage, isUploadingImages, uploadErrorMessage];
}
