import 'package:bloc/bloc.dart';

import '../../../domain/entities/hotel.dart';
import '../../../domain/repositories/hotel_repository.dart';
import 'hotel_detail_state.dart';

class HotelDetailCubit extends Cubit<HotelDetailState> {
  final HotelRepository repository;

  HotelDetailCubit(this.repository) : super(HotelDetailState.initial());

  Future<void> fetch(int id) async {
    emit(state.copyWith(status: HotelDetailStatus.loading, errorMessage: null));
    try {
      final hotel = await repository.getHotelById(id: id);
      emit(state.copyWith(status: HotelDetailStatus.success, hotel: hotel));
    } catch (e) {
      emit(state.copyWith(
        status: HotelDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> uploadImages(
      {required int hotelId, required List<String> filePaths}) async {
    if (filePaths.isEmpty) return false;
    emit(state.copyWith(isUploadingImages: true, uploadErrorMessage: null));
    try {
      final uploaded = await repository.uploadHotelImages(
        hotelId: hotelId,
        filePaths: filePaths,
      );
      final updatedHotel = _mergeHotelImages(state.hotel, uploaded);
      emit(state.copyWith(
        isUploadingImages: false,
        hotel: updatedHotel ?? state.hotel,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUploadingImages: false,
        uploadErrorMessage: e.toString(),
      ));
      return false;
    }
  }

  Hotel? _mergeHotelImages(Hotel? hotel, List<String> newImages) {
    if (hotel == null) return null;
    final existing = hotel.images;
    final merged = [...existing, ...newImages];
    return Hotel(
      id: hotel.id,
      name: hotel.name,
      address: hotel.address,
      phone: hotel.phone,
      description: hotel.description,
      category: hotel.category,
      rating: hotel.rating,
      pathImage: hotel.pathImage,
      images: merged,
      active: hotel.active,
      accountId: hotel.accountId,
      rooms: hotel.rooms,
      amenities: hotel.amenities,
      services: hotel.services,
      onCreate: hotel.onCreate,
      onUpdate: hotel.onUpdate,
    );
  }
}
