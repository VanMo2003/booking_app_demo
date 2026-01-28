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
    final now = DateTime.now();
    final defaultCheckin = _formatDate(DateTime(now.year, now.month, now.day));
    final defaultCheckout =
        _formatDate(DateTime(now.year, now.month, now.day).add(const Duration(days: 1)));
    final checkinDate = event.checkinDate ?? state.checkinDate ?? defaultCheckin;
    final checkoutDate =
        event.checkoutDate ?? state.checkoutDate ?? defaultCheckout;

    emit(state.copyWith(status: HotelStatus.loading, errorMessage: null));

    try {
      final paged = await getHotelUseCase.call(
        page: nextPage,
        size: event.size,
        checkinDate: checkinDate,
        checkoutDate: checkoutDate,
      );

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
        checkinDate: checkinDate,
        checkoutDate: checkoutDate,
      ));
    } catch (e) {
      emit(state.copyWith(status: HotelStatus.failure, errorMessage: e.toString()));
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
