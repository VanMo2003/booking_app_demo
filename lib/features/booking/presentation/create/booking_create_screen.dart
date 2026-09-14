import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../auth/presentation/session/auth_gate.dart';
import '../../../payment/presentation/payment_flow.dart';
import '../../domain/entities/booking.dart';
import '../widgets/booking_form_sections.dart';
import 'booking_create_cubit.dart';

@RoutePage()
class BookingCreateScreen extends StatelessWidget {
  const BookingCreateScreen({
    super.key,
    required this.hotelId,
    required this.checkin,
    required this.checkout,
    this.preselectedRoomIds = const [],
  });

  final int hotelId;
  final DateTime checkin;
  final DateTime checkout;
  final List<int> preselectedRoomIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingCreateCubit>()
        ..start(
          hotelId: hotelId,
          checkin: checkin,
          checkout: checkout,
          preselectedRoomIds: preselectedRoomIds,
        ),
      child: const _BookingCreateView(),
    );
  }
}

class _BookingCreateView extends StatefulWidget {
  const _BookingCreateView();

  @override
  State<_BookingCreateView> createState() => _BookingCreateViewState();
}

class _BookingCreateViewState extends State<_BookingCreateView> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final customer = await context.ensureCustomer();
    if (customer == null || !mounted) return;
    await context.read<BookingCreateCubit>().submit(
          customerId: customer.id,
          note: _note.text,
        );
  }

  Future<void> _afterCreated(Booking booking) async {
    if (booking.paymentMethod == PaymentMethod.vnPay) {
      await PaymentFlow.payBooking(context, booking);
    } else {
      AppToast.success(context, BookingStrings.created);
    }
    if (mounted) await context.router.replace(BookingDetailRoute(bookingId: booking.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCreateCubit, BookingCreateState>(
      listenWhen: (previous, current) =>
          current.error != null || previous.created != current.created,
      listener: (context, state) {
        if (state.error != null) AppToast.error(context, state.error!);
        if (state.created != null) _afterCreated(state.created!);
      },
      builder: (context, state) {
        final cubit = context.read<BookingCreateCubit>();
        final detail = state.detail.data;
        final pricing = state.pricing;
        return AppPage(
          title: BookingStrings.createTitle,
          body: detail == null
              ? (state.detail.isFailure
                  ? AppFailureView.fromState(state.detail, onRetry: cubit.reload)
                  : const AppLoadingView())
              : ListView(
                  padding: AppSpacing.page,
                  children: [
                    BranchSummaryCard(hotel: detail.hotel),
                    const Gap(AppSpacing.xl),
                    const SectionHeader(title: BookingStrings.stepStay),
                    const Gap(AppSpacing.xs),
                    StayDatesCard(
                      checkin: state.checkin,
                      checkout: state.checkout,
                      onChanged: cubit.changeDates,
                    ),
                    if (state.detail.isLoading) ...[
                      const Gap(AppSpacing.xs),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    const Gap(AppSpacing.xl),
                    SectionHeader(
                      title: BookingStrings.stepRooms,
                      subtitle: ExploreStrings.availableRooms(detail.availableRooms.length),
                    ),
                    const Gap(AppSpacing.sm),
                    RoomChoiceList(
                      rooms: detail.rooms,
                      selectedIds: state.selectedRoomIds,
                      onToggle: cubit.toggleRoom,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepServices),
                    const Gap(AppSpacing.sm),
                    ServiceChoiceList(
                      services: detail.hotel.services,
                      selectedIds: state.selectedServiceIds,
                      onToggle: cubit.toggleService,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepPayment),
                    const Gap(AppSpacing.sm),
                    PaymentMethodPicker(
                      selected: state.paymentMethod,
                      onSelected: cubit.selectPayment,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: BookingStrings.stepNote),
                    const Gap(AppSpacing.sm),
                    AppTextField(
                      controller: _note,
                      hint: BookingStrings.noteHint,
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
          bottomBar: detail == null
              ? null
              : TotalActionBar(
                  label: BookingStrings.totalLabel,
                  amount: pricing.total,
                  detail: [
                    BookingStrings.roomsLine(state.selectedRoomIds.length, state.nights),
                    if (state.selectedServiceIds.isNotEmpty)
                      BookingStrings.servicesLine(state.selectedServiceIds.length),
                  ].join(' · '),
                  actionLabel: BookingStrings.submit,
                  loading: state.submitting,
                  onAction: state.canSubmit ? _submit : null,
                ),
        );
      },
    );
  }
}
