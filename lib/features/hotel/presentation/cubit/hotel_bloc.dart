import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/hotel/domain/use_case/get_hotel_use_case.dart';

import '../../domain/entities/hotel.dart';
import 'hotel_event.dart';
import 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final GetHotelUseCase getHotelUseCase;

  HotelBloc({required this.getHotelUseCase}) : super(HotelState.initial()) {
    on<HotelsFetched>(_onFetched);
  }

  Future<void> _onFetched(HotelsFetched event, Emitter<HotelState> emit) async {
    if (state.status == HotelStatus.loading) return;
    if (!event.refresh && !state.hasMore) return;

    final nextPage = event.refresh ? 0 : event.page;

    emit(state.copyWith(status: HotelStatus.loading, errorMessage: null));

    try {
      final paged = await getHotelUseCase.call(page: nextPage, size: event.size);

      final List<Hotel> items = event.refresh ? <Hotel>[] : List<Hotel>.from(state.items);
      items.addAll(paged.content);

      bool hasMore;
      if (paged.totalPages != null) {
        hasMore = (nextPage + 1) < paged.totalPages!;
      } else {
        hasMore = paged.content.length == event.size;
      }

      emit(state.copyWith(
        status: HotelStatus.success,
        items: items,
        page: nextPage + 1,
        size: event.size,
        hasMore: hasMore,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: HotelStatus.failure, errorMessage: e.toString()));
    }
  }
}
