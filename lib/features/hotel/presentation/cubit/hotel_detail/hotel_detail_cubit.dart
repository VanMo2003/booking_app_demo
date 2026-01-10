import 'package:bloc/bloc.dart';

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
}
