import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/create_amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/delete_amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/get_by_hotel.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/get_by_room.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/update_amenity.dart';

import 'amenity_event.dart';
import 'amenity_state.dart';

class AmenityBloc extends Bloc<AmenityEvent, AmenityState> {
  final CreateAmenity createAmenity;
  final UpdateAmenity updateAmenity;
  final DeleteAmenity deleteAmenity;
  final GetAmenityByHotel getAmenityByHotel;
  final GetAmenityByRoom getAmenityByRoom;

  AmenityBloc(
      {required this.createAmenity,
      required this.deleteAmenity,
      required this.updateAmenity,
      required this.getAmenityByRoom,
      required this.getAmenityByHotel})
      : super(AmenityState.initial()) {
    on<AmenitiesByHotelFetched>(_onByHotelFetched);
    on<AmenitiesByRoomFetched>(_onByRoomFetched);
    on<AmenityCreated>(_onCreated);
    on<AmenityUpdated>(_onUpdated);
    on<AmenityDeleted>(_onDeleted);
  }

  Future<void> _onByHotelFetched(AmenitiesByHotelFetched event, Emitter<AmenityState> emit) async {
    emit(state.copyWith(status: AmenityStatus.loading, errorMessage: null, clearOneOff: true));
    try {
      final items = await getAmenityByHotel.call(event.hotelId);
      emit(state.copyWith(status: AmenityStatus.success, items: items, errorMessage: null, clearOneOff: true));
    } catch (e) {
      emit(state.copyWith(status: AmenityStatus.failure, errorMessage: e.toString(), clearOneOff: true));
    }
  }

  Future<void> _onByRoomFetched(AmenitiesByRoomFetched event, Emitter<AmenityState> emit) async {
    emit(state.copyWith(status: AmenityStatus.loading, errorMessage: null, clearOneOff: true));
    try {
      final items = await getAmenityByRoom.call(hotelId: event.hotelId, roomId: event.roomId);
      emit(state.copyWith(status: AmenityStatus.success, items: items, errorMessage: null, clearOneOff: true));
    } catch (e) {
      emit(state.copyWith(status: AmenityStatus.failure, errorMessage: e.toString(), clearOneOff: true));
    }
  }

  Future<void> _onCreated(AmenityCreated event, Emitter<AmenityState> emit) async {
    emit(state.copyWith(status: AmenityStatus.loading, errorMessage: null, clearOneOff: true));
    try {
      final created = await createAmenity.call(event.request);
      emit(state.copyWith(
        status: AmenityStatus.success,
        items: [created, ...state.items],
        lastCreatedOrUpdated: created,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AmenityStatus.failure, errorMessage: e.toString(), clearOneOff: true));
    }
  }

  Future<void> _onUpdated(AmenityUpdated event, Emitter<AmenityState> emit) async {
    emit(state.copyWith(status: AmenityStatus.loading, errorMessage: null, clearOneOff: true));
    try {
      final updated = await updateAmenity.call(event.id, event.request);
      final items = state.items.map((a) => a.id == event.id ? updated : a).toList();
      emit(state.copyWith(
        status: AmenityStatus.success,
        items: items,
        lastCreatedOrUpdated: updated,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AmenityStatus.failure, errorMessage: e.toString(), clearOneOff: true));
    }
  }

  Future<void> _onDeleted(AmenityDeleted event, Emitter<AmenityState> emit) async {
    emit(state.copyWith(status: AmenityStatus.loading, errorMessage: null, clearOneOff: true));
    try {
      await deleteAmenity.call(event.id);
      final items = state.items.where((a) => a.id != event.id).toList();
      emit(state.copyWith(
        status: AmenityStatus.success,
        items: items,
        lastDeletedId: event.id,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AmenityStatus.failure, errorMessage: e.toString(), clearOneOff: true));
    }
  }
}
