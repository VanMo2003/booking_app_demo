import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/ai_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../chat/presentation/chat_entry.dart';
import '../../domain/entities/tour_booking.dart';
import '../../domain/usecases/tour_booking_usecases.dart';

@injectable
class TourBookingDetailCubit extends LoadCubit<TourBooking> {
  TourBookingDetailCubit(this._getBooking, this._changeStatus, this._cancel);

  final GetTourBooking _getBooking;
  final ChangeTourBookingStatus _changeStatus;
  final CancelTourBooking _cancel;
  late int _bookingId;

  Future<void> start(int bookingId) {
    _bookingId = bookingId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getBooking(_bookingId));

  Future<ActionResult<TourBooking>> perform(TourBookingAction action) =>
      _apply(() => _changeStatus(_bookingId, action));

  Future<ActionResult<TourBooking>> cancel({String? reason}) => _apply(() => _cancel(_bookingId, reason: reason));

  Future<ActionResult<TourBooking>> _apply(Future<TourBooking> Function() task) async {
    final result = await runAction(task);
    if (result.isSuccess && !isClosed) emit(state.toSuccess(result.value as TourBooking));
    return result;
  }
}

/// Chi tiết đơn tour — khách xem và huỷ đơn của mình; đội ngũ cơ sở xác nhận, hoàn tất, huỷ (kèm lý do).
/// Mở từ danh sách đơn tour hoặc từ thông báo (`bookingapp://tour-bookings/{id}`).
@RoutePage()
class TourBookingDetailScreen extends StatelessWidget {
  const TourBookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TourBookingDetailCubit>()..start(bookingId),
      child: _DetailView(bookingId: bookingId),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.bookingId});

  final int bookingId;

  Future<void> _run(BuildContext context, TourBookingAction action, String success) async {
    final cubit = context.read<TourBookingDetailCubit>();
    await AppAction.run(context, () => cubit.perform(action), successMessage: success);
  }

  Future<void> _complete(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: TourBookingStrings.completeTitle,
      message: TourBookingStrings.completeMessage,
      confirmLabel: TourBookingStrings.complete,
    );
    if (confirmed && context.mounted) {
      await _run(context, TourBookingAction.complete, TourBookingStrings.completed);
    }
  }

  Future<void> _cancel(BuildContext context, {required bool forGuest}) async {
    final cubit = context.read<TourBookingDetailCubit>();
    String? reason;
    if (forGuest) {
      final confirmed = await AppDialogs.confirm(
        context,
        title: TourBookingStrings.cancelTitle,
        message: TourBookingStrings.cancelMessageGuest,
        confirmLabel: TourBookingStrings.cancel,
        destructive: true,
      );
      if (!confirmed) return;
    } else {
      reason = await AppDialogs.sheet<String>(
        context,
        title: TourBookingStrings.cancelReasonTitle,
        builder: (_) => const _CancelReasonSheet(),
      );
      if (reason == null) return;
    }
    if (!context.mounted) return;
    await AppAction.run(context, () => cubit.cancel(reason: reason), successMessage: TourBookingStrings.canceled);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<SessionCubit>().state.role;
    final forGuest = role == Role.customer;
    final canAct = forGuest || (role?.canEditBranchContent ?? false);
    return BlocBuilder<TourBookingDetailCubit, LoadState<TourBooking>>(
      builder: (context, state) {
        final booking = state.data;
        return AppPage(
          title: TourBookingStrings.code(bookingId),
          subtitle: booking?.status.label,
          actions: [
            if (booking != null && forGuest)
              IconButton(
                tooltip: ChatStrings.messageHotel,
                onPressed: () => context.openHotelChat(booking.hotelId),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            if (booking?.conversationId != null && !forGuest && role != Role.admin)
              IconButton(
                tooltip: TourBookingStrings.openChat,
                onPressed: () => context.router.push(ChatRoute(conversationId: booking!.conversationId!)),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
          ],
          body: LoadStateView<TourBooking>(
            state: state,
            onRetry: context.read<TourBookingDetailCubit>().load,
            builder: (context, booking) => RefreshIndicator(
              onRefresh: context.read<TourBookingDetailCubit>().load,
              child: _Body(booking: booking, forGuest: forGuest),
            ),
          ),
          bottomBar: booking == null || !canAct || !booking.status.isOpen
              ? null
              : BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          variant: AppButtonVariant.dangerOutline,
                          label: TourBookingStrings.cancel,
                          onPressed: () => _cancel(context, forGuest: forGuest),
                        ),
                      ),
                      if (!forGuest) ...[
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: booking.status == TourBookingStatus.pending
                              ? AppButton(
                                  label: TourBookingStrings.confirm,
                                  icon: Icons.check_circle_outline_rounded,
                                  onPressed: () =>
                                      _run(context, TourBookingAction.confirm, TourBookingStrings.confirmed),
                                )
                              : AppButton(
                                  label: TourBookingStrings.complete,
                                  icon: Icons.flag_outlined,
                                  onPressed: () => _complete(context),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.booking, required this.forGuest});

  final TourBooking booking;
  final bool forGuest;

  @override
  Widget build(BuildContext context) {
    final canceled = booking.status == TourBookingStatus.canceled;
    return ListView(
      padding: AppSpacing.page,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppNetworkImage(
                path: booking.tourPathImage,
                height: 150,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                placeholderIcon: Icons.tour_outlined,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.tourName, style: AppTextStyles.subtitle),
                    const Gap(AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusBadge.tourBooking(booking.status),
                              if (booking.createdByAi)
                                const SoftTag(label: AiStrings.assistantName, icon: Icons.auto_awesome_rounded),
                            ],
                          ),
                        ),
                        Text(
                          Fmt.money(booking.totalAmount),
                          style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (forGuest && booking.status == TourBookingStatus.pending) ...[
          const Gap(AppSpacing.md),
          const NoticeBanner(text: TourBookingStrings.waitingNotice, icon: Icons.hourglass_top_rounded),
        ],
        if (canceled) ...[
          const Gap(AppSpacing.md),
          NoticeBanner(
            tone: StatusTone.danger,
            icon: Icons.cancel_outlined,
            text: [
              booking.canceledByGuest ? TourBookingStrings.canceledByGuest : TourBookingStrings.canceledByHotel,
              if ((booking.cancelReason ?? '').isNotEmpty) '${TourBookingStrings.cancelReason}: ${booking.cancelReason}',
            ].join(' · '),
          ),
        ],
        const Gap(AppSpacing.md),
        _PartyCard(
          title: forGuest ? booking.hotelName : booking.customerName,
          caption: forGuest ? TourBookingStrings.branch : '${TourBookingStrings.guest} · ${booking.customerPhone}',
          phone: forGuest ? booking.hotelPhone : booking.customerPhone,
          callLabel: forGuest ? TourBookingStrings.callBranch : TourBookingStrings.callGuest,
          forGuest: forGuest,
        ),
        if (booking.withRooms) ...[
          const Gap(AppSpacing.md),
          const SectionHeader(title: TourBookingStrings.stay),
          const Gap(AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoRow(label: TourBookingStrings.checkin, value: Fmt.weekdayDate(booking.tourDate)),
                if (booking.stayCheckout != null)
                  InfoRow(label: TourBookingStrings.checkout, value: Fmt.weekdayDate(booking.stayCheckout!)),
                for (final room in booking.rooms)
                  InfoRow(
                    icon: Icons.bed_outlined,
                    label: 'Phòng ${room.roomNumber} · ${room.roomTypeName}',
                    value: '${Fmt.money(room.price)}${TourStrings.perNight}',
                  ),
                if (booking.bookingId != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.router.push(BookingDetailRoute(bookingId: booking.bookingId!)),
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: Text(TourBookingStrings.viewRoomBooking(booking.bookingId!)),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const Gap(AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(label: TourBookingStrings.tourDate, value: Fmt.weekdayDate(booking.tourDate)),
              if (booking.tourDeparture != null)
                InfoRow(label: TourBookingStrings.departure, value: booking.tourDeparture!),
              if (booking.tourDuration != null) InfoRow(label: TourStrings.duration, value: booking.tourDuration!),
              InfoRow(label: TourBookingStrings.guestCount, value: TourBookingStrings.guests(booking.guests)),
              InfoRow(label: TourBookingStrings.unitPrice, value: Fmt.money(booking.unitPrice)),
              if (booking.tourAmount != null)
                InfoRow(label: TourBookingStrings.tourAmount, value: Fmt.money(booking.tourAmount)),
              if (booking.roomAmount > 0)
                InfoRow(label: TourBookingStrings.roomAmount, value: Fmt.money(booking.roomAmount)),
              const Divider(),
              InfoRow(
                label: TourBookingStrings.total,
                value: Fmt.money(booking.totalAmount),
                valueStyle: AppTextStyles.money.colored(AppColors.primaryDark),
              ),
              const InfoRow(label: TourBookingStrings.payment, value: TourBookingStrings.paymentAtHotel),
            ],
          ),
        ),
        if ((booking.note ?? '').isNotEmpty) ...[
          const Gap(AppSpacing.md),
          const SectionHeader(title: TourBookingStrings.note),
          const Gap(AppSpacing.xs),
          AppCard(child: Text(booking.note!, style: AppTextStyles.body)),
        ],
        const Gap(AppSpacing.md),
        Text(
          [
            if (booking.createdAt != null) '${TourBookingStrings.createdAt} ${Fmt.dateTime(booking.createdAt)}',
            if (booking.createdByAi) TourBookingStrings.viaAi,
            if (booking.tourId == null) TourBookingStrings.tourRemoved,
          ].join('\n'),
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.title,
    required this.caption,
    required this.phone,
    required this.callLabel,
    required this.forGuest,
  });

  final String title;
  final String caption;
  final String phone;
  final String callLabel;
  final bool forGuest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          forGuest
              ? const Icon(Icons.apartment_rounded, color: AppColors.primary)
              : AppAvatar(name: title, size: 44),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(caption, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            IconButton.filledTonal(
              tooltip: callLabel,
              onPressed: () => ExternalActions.call(phone),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primaryDark,
              ),
              icon: const Icon(Icons.phone_rounded),
            ),
        ],
      ),
    );
  }
}

/// Phía cơ sở huỷ đơn: bắt buộc lý do (khách nhận trong thông báo), có vài lý do chọn nhanh.
class _CancelReasonSheet extends StatefulWidget {
  const _CancelReasonSheet();

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(TourBookingStrings.cancelReasonHint, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final reason in TourBookingStrings.quickReasons)
                ActionChip(
                  label: Text(reason, style: AppTextStyles.chip),
                  onPressed: () => _reason.text = reason,
                ),
            ],
          ),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _reason,
            label: TourBookingStrings.cancelReason,
            minLines: 2,
            maxLines: 4,
            maxLength: 255,
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required(TourBookingStrings.cancelReasonRequired),
          ),
          const Gap(AppSpacing.md),
          AppButton(
            variant: AppButtonVariant.danger,
            label: TourBookingStrings.cancel,
            expand: true,
            onPressed: () {
              if (_form.currentState!.validate()) Navigator.of(context).pop(_reason.text.trim());
            },
          ),
        ],
      ),
    );
  }
}
