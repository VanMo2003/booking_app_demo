import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../create/booking_create_cubit.dart';
import '../widgets/booking_form_sections.dart';
import 'walk_in_guest_cubit.dart';

/// Khách đến quầy không có tài khoản: tìm/tạo hồ sơ → chọn ngày & phòng →
/// dịch vụ & thanh toán → xác nhận.
@RoutePage()
class WalkInBookingScreen extends StatelessWidget {
  const WalkInBookingScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    final today = DateOnly.today();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<WalkInGuestCubit>()),
        BlocProvider(
          create: (_) => getIt<BookingCreateCubit>()
            ..start(
              hotelId: hotelId,
              checkin: today,
              checkout: DateOnly.addDays(today, 1),
              paymentMethod: PaymentMethod.cash,
            ),
        ),
      ],
      child: const _WalkInView(),
    );
  }
}

class _WalkInView extends StatefulWidget {
  const _WalkInView();

  @override
  State<_WalkInView> createState() => _WalkInViewState();
}

class _WalkInViewState extends State<_WalkInView> {
  static const _steps = [
    BookingStrings.stepGuest,
    BookingStrings.stepDatesRooms,
    BookingStrings.stepExtras,
    BookingStrings.stepConfirm,
  ];

  int _step = 0;
  final _phoneForm = GlobalKey<FormState>();
  final _guestForm = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _fullName = TextEditingController();
  final _note = TextEditingController();
  String? _gender;
  String? _hometown;

  @override
  void dispose() {
    _phone.dispose();
    _fullName.dispose();
    _note.dispose();
    super.dispose();
  }

  bool _canContinue(WalkInGuestState guest, BookingCreateState booking) => switch (_step) {
        0 => guest.selected != null,
        1 => booking.selectedRoomIds.isNotEmpty && !booking.detail.isLoading,
        2 => true,
        _ => booking.canSubmit && guest.selected != null,
      };

  Future<void> _next(WalkInGuestState guest, BookingCreateState booking) async {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }
    await context.read<BookingCreateCubit>().submit(
          customerId: guest.selected!.id,
          note: _note.text,
        );
  }

  Future<void> _afterCreated(Booking booking) async {
    final choice = await AppDialogs.choose<String>(
      context,
      title: BookingStrings.bookingCreated(booking.id),
      choices: const [
        AppChoice(
          value: 'collect',
          label: BookingStrings.confirmAndCollect,
          icon: Icons.payments_outlined,
        ),
        AppChoice(
          value: 'confirm',
          label: BookingStrings.confirmOnly,
          icon: Icons.check_circle_outline_rounded,
        ),
        AppChoice(value: 'later', label: BookingStrings.later, icon: Icons.schedule_rounded),
      ],
    );
    if (!mounted) return;
    if (choice == 'collect' || choice == 'confirm') {
      final change = getIt<ChangeBookingStatus>();
      await AppAction.run<void>(
        context,
        () => runAction<void>(() async {
          await change(booking.id, BookingAction.confirm);
          if (choice == 'collect') await change(booking.id, BookingAction.markPaid);
        }),
        successMessage: choice == 'collect' ? BookingStrings.markedPaid : BookingStrings.confirmed,
      );
    }
    if (mounted) await context.router.replace(BookingDetailRoute(bookingId: booking.id));
  }

  @override
  Widget build(BuildContext context) {
    final guest = context.watch<WalkInGuestCubit>().state;
    return BlocConsumer<BookingCreateCubit, BookingCreateState>(
      listenWhen: (previous, current) =>
          current.error != null || previous.created != current.created,
      listener: (context, state) {
        if (state.error != null) AppToast.error(context, state.error!);
        if (state.created != null) _afterCreated(state.created!);
      },
      builder: (context, booking) {
        return BlocListener<WalkInGuestCubit, WalkInGuestState>(
          listenWhen: (previous, current) => current.error != null,
          listener: (context, state) => AppToast.error(context, state.error!),
          child: AppPage(
            title: BookingStrings.walkInTitle,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: StepProgress(steps: _steps, current: _step),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: AppSpacing.page,
                    children: switch (_step) {
                      0 => _guestStep(guest),
                      1 => _roomsStep(booking),
                      2 => _extrasStep(booking),
                      _ => _confirmStep(guest, booking),
                    },
                  ),
                ),
              ],
            ),
            bottomBar: BottomActionBar(
              child: Row(
                children: [
                  if (_step > 0) ...[
                    AppButton.secondary(
                      label: AppStrings.back,
                      onPressed: booking.submitting ? null : () => setState(() => _step--),
                    ),
                    const Gap(AppSpacing.sm),
                  ],
                  Expanded(
                    child: AppButton(
                      label: _step == _steps.length - 1
                          ? BookingStrings.createBooking
                          : AppStrings.next,
                      loading: booking.submitting,
                      onPressed: _canContinue(guest, booking) ? () => _next(guest, booking) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _guestStep(WalkInGuestState guest) {
    final cubit = context.read<WalkInGuestCubit>();
    final selected = guest.selected;
    return [
      Form(
        key: _phoneForm,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _phone,
                label: BookingStrings.guestPhone,
                helper: BookingStrings.guestPhoneHint,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                validator: Validators.phone,
                onSubmitted: (_) {
                  if (_phoneForm.currentState!.validate()) cubit.search(_phone.text);
                },
              ),
            ),
            const Gap(AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AppButton.tonal(
                label: BookingStrings.findGuest,
                loading: guest.searching,
                onPressed: () {
                  if (_phoneForm.currentState!.validate()) cubit.search(_phone.text);
                },
              ),
            ),
          ],
        ),
      ),
      if (guest.results.isNotEmpty) ...[
        const Gap(AppSpacing.lg),
        const GroupLabel(BookingStrings.guestFound),
        for (final customer in guest.results) ...[
          SelectableCard(
            multiple: false,
            selected: selected?.id == customer.id,
            onTap: () => cubit.select(customer),
            child: _GuestRow(customer: customer),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
      if (guest.notFound) ...[
        const Gap(AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(color: AppColors.infoSoft, borderRadius: AppRadius.smAll),
          child: IconText(
            icon: Icons.person_add_alt_1_outlined,
            iconColor: AppColors.info,
            maxLines: 3,
            text: BookingStrings.guestNotFound,
            style: AppTextStyles.bodySmall.colored(AppColors.info),
          ),
        ),
        const Gap(AppSpacing.md),
        Form(
          key: _guestForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _fullName,
                label: ExploreStrings.fullName,
                prefixIcon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: Validators.required(),
              ),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: ExploreStrings.gender,
                      items: AppConstants.genders,
                      value: _gender,
                      itemLabel: (item) => item,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: AppDropdownField<String>(
                      label: ExploreStrings.hometown,
                      items: AppConstants.provinces,
                      value: _hometown,
                      itemLabel: (item) => item,
                      onChanged: (value) => setState(() => _hometown = value),
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.md),
              AppButton(
                label: BookingStrings.createGuest,
                icon: Icons.person_add_alt_1_rounded,
                loading: guest.creating,
                onPressed: () {
                  if (!_guestForm.currentState!.validate()) return;
                  cubit.createAndSelect(
                    fullName: _fullName.text,
                    phone: guest.searchedPhone ?? _phone.text,
                    gender: _gender ?? '',
                    hometown: _hometown ?? '',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _roomsStep(BookingCreateState booking) {
    final cubit = context.read<BookingCreateCubit>();
    final detail = booking.detail.data;
    return [
      const SectionHeader(title: BookingStrings.stepStay),
      const Gap(AppSpacing.xs),
      StayDatesCard(checkin: booking.checkin, checkout: booking.checkout, onChanged: cubit.changeDates),
      if (booking.detail.isLoading) ...[
        const Gap(AppSpacing.xs),
        const LinearProgressIndicator(minHeight: 2),
      ],
      const Gap(AppSpacing.xl),
      SectionHeader(
        title: BookingStrings.stepRooms,
        subtitle: detail == null ? null : ExploreStrings.availableRooms(detail.availableRooms.length),
      ),
      const Gap(AppSpacing.sm),
      if (detail == null)
        booking.detail.isFailure
            ? AppErrorView(message: booking.detail.error!)
            : const AppLoadingView()
      else
        RoomChoiceList(
          rooms: detail.rooms,
          selectedIds: booking.selectedRoomIds,
          onToggle: cubit.toggleRoom,
        ),
    ];
  }

  List<Widget> _extrasStep(BookingCreateState booking) {
    final cubit = context.read<BookingCreateCubit>();
    return [
      const SectionHeader(title: BookingStrings.stepServices),
      const Gap(AppSpacing.sm),
      ServiceChoiceList(
        services: booking.detail.data?.hotel.services ?? const [],
        selectedIds: booking.selectedServiceIds,
        onToggle: cubit.toggleService,
      ),
      const Gap(AppSpacing.lg),
      const SectionHeader(title: BookingStrings.stepPayment),
      const Gap(AppSpacing.sm),
      PaymentMethodPicker(
        selected: booking.paymentMethod,
        methods: const [PaymentMethod.cash, PaymentMethod.bankTransfer],
        onSelected: cubit.selectPayment,
      ),
      const Gap(AppSpacing.lg),
      const SectionHeader(title: BookingStrings.stepNote),
      const Gap(AppSpacing.sm),
      AppTextField(controller: _note, hint: BookingStrings.noteHint, minLines: 2, maxLines: 4),
    ];
  }

  List<Widget> _confirmStep(WalkInGuestState guest, BookingCreateState booking) {
    final pricing = booking.pricing;
    return [
      if (guest.selected != null) ...[
        const GroupLabel(BookingStrings.selectedGuest),
        AppCard(child: _GuestRow(customer: guest.selected!)),
        const Gap(AppSpacing.md),
      ],
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          children: [
            InfoRow(
              label: BookingStrings.stay,
              value:
                  '${Fmt.dayMonth(booking.checkin)} → ${Fmt.dayMonth(booking.checkout)} · ${AppStrings.nights(booking.nights)}',
            ),
            InfoRow(
              label: BookingStrings.roomsBooked,
              value: booking.selectedRooms.map((room) => room.roomNumber).join(', '),
            ),
            if (booking.selectedServices.isNotEmpty)
              InfoRow(
                label: BookingStrings.servicesBooked,
                value: booking.selectedServices.map((service) => service.name).join(', '),
              ),
            InfoRow(label: BookingStrings.paymentMethod, value: booking.paymentMethod.label),
            const Divider(),
            InfoRow(label: BookingStrings.roomsSubtotal, value: Fmt.money(pricing.roomsSubtotal)),
            if (pricing.servicesSubtotal > 0)
              InfoRow(label: BookingStrings.servicesSubtotal, value: Fmt.money(pricing.servicesSubtotal)),
            InfoRow(
              label: BookingStrings.totalLabel,
              value: Fmt.money(pricing.total),
              valueStyle: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
            ),
          ],
        ),
      ),
    ];
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: customer.fullName, size: 40),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.fullName, style: AppTextStyles.bodyStrong),
              Text(customer.phoneNumber, style: AppTextStyles.caption),
            ],
          ),
        ),
        SoftTag(
          label: customer.isWalkIn ? WorkspaceStrings.walkInBadge : WorkspaceStrings.accountBadge,
          tone: customer.isWalkIn ? StatusTone.neutral : StatusTone.brand,
        ),
      ],
    );
  }
}