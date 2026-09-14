import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel/domain/usecases/hotel_usecases.dart';
import '../../data/models/booking_models.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_pricing.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../widgets/booking_form_sections.dart';

class BookingEditState extends Equatable {
  const BookingEditState({
    this.booking,
    this.detail = const LoadState(),
    this.checkin,
    this.checkout,
    this.roomIds = const {},
    this.serviceIds = const {},
    this.paymentMethod = PaymentMethod.cash,
    this.saving = false,
    this.saved = false,
    this.error,
  });

  final Booking? booking;
  final LoadState<HotelDetail> detail;
  final DateTime? checkin;
  final DateTime? checkout;
  final Set<int> roomIds;
  final Set<int> serviceIds;
  final PaymentMethod paymentMethod;
  final bool saving;
  final bool saved;
  final String? error;

  BookingPricing get pricing {
    final data = detail.data;
    return BookingPricing(
      rooms: data?.rooms.where((r) => roomIds.contains(r.id)).toList() ?? const [],
      services: data?.hotel.services.where((s) => serviceIds.contains(s.id)).toList() ?? const [],
      nights: checkin == null || checkout == null ? 0 : DateOnly.nights(checkin!, checkout!),
    );
  }

  BookingEditState copyWith({
    Booking? booking,
    LoadState<HotelDetail>? detail,
    DateTime? checkin,
    DateTime? checkout,
    Set<int>? roomIds,
    Set<int>? serviceIds,
    PaymentMethod? paymentMethod,
    bool? saving,
    bool? saved,
    String? error,
  }) =>
      BookingEditState(
        booking: booking ?? this.booking,
        detail: detail ?? this.detail,
        checkin: checkin ?? this.checkin,
        checkout: checkout ?? this.checkout,
        roomIds: roomIds ?? this.roomIds,
        serviceIds: serviceIds ?? this.serviceIds,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        error: error,
      );

  @override
  List<Object?> get props =>
      [booking, detail, checkin, checkout, roomIds, serviceIds, paymentMethod, saving, saved, error];
}

@injectable
class BookingEditCubit extends Cubit<BookingEditState> {
  BookingEditCubit(this._getBooking, this._getDetail, this._update) : super(const BookingEditState());

  final GetBooking _getBooking;
  final GetHotelDetail _getDetail;
  final UpdateBooking _update;

  Future<void> start(int bookingId) async {
    emit(state.copyWith(detail: const LoadState(status: ViewStatus.loading)));
    try {
      final booking = await _getBooking(bookingId);
      emit(state.copyWith(
        booking: booking,
        checkin: booking.checkinDate,
        checkout: booking.checkoutDate,
        roomIds: booking.rooms.map((r) => r.roomId).toSet(),
        serviceIds: booking.services.map((s) => s.serviceId).toSet(),
        paymentMethod: booking.paymentMethod,
      ));
      await _fetchDetail();
    } catch (error) {
      emit(state.copyWith(detail: state.detail.toError(error)));
    }
  }

  Future<void> _fetchDetail() async {
    final hotelId = state.booking?.hotel?.id;
    if (hotelId == null) return;
    try {
      final detail = await _getDetail(hotelId, checkin: state.checkin, checkout: state.checkout);
      if (!isClosed) emit(state.copyWith(detail: state.detail.toSuccess(detail)));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(detail: state.detail.toError(error)));
    }
  }

  Future<void> changeDates(DateTimeRange range) {
    emit(state.copyWith(checkin: range.start, checkout: range.end, detail: state.detail.toLoading()));
    return _fetchDetail();
  }

  void toggleRoom(int id) {
    final ids = {...state.roomIds};
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    emit(state.copyWith(roomIds: ids));
  }

  void toggleService(int id) {
    final ids = {...state.serviceIds};
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    emit(state.copyWith(serviceIds: ids));
  }

  void selectPayment(PaymentMethod method) => emit(state.copyWith(paymentMethod: method));

  Future<void> save(String note) async {
    final booking = state.booking;
    if (booking == null || state.roomIds.isEmpty) return;
    emit(state.copyWith(saving: true));
    try {
      await _update(
        booking.id,
        BookingUpdateRequest(
          checkinDate: state.checkin!,
          checkoutDate: state.checkout!,
          status: booking.status,
          paymentMethod: state.paymentMethod,
          hotelId: booking.hotel!.id,
          customerId: booking.customer!.id,
          roomIds: state.roomIds.toList(),
          serviceIds: state.serviceIds.toList(),
          totalAmount: state.pricing.total,
          note: note,
        ),
      );
      emit(state.copyWith(saving: false, saved: true));
    } catch (error) {
      emit(state.copyWith(saving: false, error: AppException.from(error).message));
    }
  }
}

@RoutePage()
class BookingEditScreen extends StatelessWidget {
  const BookingEditScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingEditCubit>()..start(bookingId),
      child: _BookingEditView(bookingId: bookingId),
    );
  }
}

class _BookingEditView extends StatefulWidget {
  const _BookingEditView({required this.bookingId});

  final int bookingId;

  @override
  State<_BookingEditView> createState() => _BookingEditViewState();
}

class _BookingEditViewState extends State<_BookingEditView> {
  final _note = TextEditingController();
  bool _noteLoaded = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingEditCubit, BookingEditState>(
      listener: (context, state) {
        if (state.error != null) AppToast.error(context, state.error!);
        if (state.saved) {
          AppToast.success(context, BookingStrings.editSaved);
          context.router.maybePop(true);
        }
        if (!_noteLoaded && state.booking != null) {
          _noteLoaded = true;
          _note.text = state.booking!.note ?? '';
        }
      },
      builder: (context, state) {
        final cubit = context.read<BookingEditCubit>();
        final booking = state.booking;
        final detail = state.detail.data;
        final keepIds = booking?.rooms.map((r) => r.roomId).toSet() ?? <int>{};
        return AppPage(
          title: BookingStrings.editTitle(widget.bookingId),
          body: booking == null || detail == null
              ? (state.detail.isFailure
                  ? AppFailureView.fromState(
                      state.detail,
                      onRetry: () => cubit.start(widget.bookingId),
                    )
                  : const AppLoadingView())
              : ListView(
                  padding: AppSpacing.page,
                  children: [
                    const SectionHeader(title: BookingStrings.stepStay),
                    const Gap(AppSpacing.xs),
                    StayDatesCard(checkin: state.checkin, checkout: state.checkout, onChanged: cubit.changeDates),
                    if (state.detail.isLoading) const LinearProgressIndicator(minHeight: 2),
                    const Gap(AppSpacing.xl),
                    const SectionHeader(title: BookingStrings.stepRooms, subtitle: BookingStrings.keepCurrentRooms),
                    const Gap(AppSpacing.sm),
                    RoomChoiceList(
                      rooms: detail.rooms,
                      selectedIds: state.roomIds,
                      keepIds: keepIds,
                      onToggle: cubit.toggleRoom,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepServices),
                    const Gap(AppSpacing.sm),
                    ServiceChoiceList(
                      services: detail.hotel.services,
                      selectedIds: state.serviceIds,
                      onToggle: cubit.toggleService,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepPayment),
                    const Gap(AppSpacing.sm),
                    PaymentMethodPicker(selected: state.paymentMethod, onSelected: cubit.selectPayment),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepNote),
                    const Gap(AppSpacing.sm),
                    AppTextField(controller: _note, hint: BookingStrings.noteHint, minLines: 2, maxLines: 4),
                  ],
                ),
          bottomBar: booking == null
              ? null
              : TotalActionBar(
                  label: BookingStrings.totalLabel,
                  amount: state.pricing.total,
                  detail: BookingStrings.roomsLine(state.roomIds.length, state.pricing.nights),
                  actionLabel: AppStrings.saveChanges,
                  loading: state.saving,
                  onAction: state.roomIds.isEmpty ? null : () => cubit.save(_note.text),
                ),
        );
      },
    );
  }
}
