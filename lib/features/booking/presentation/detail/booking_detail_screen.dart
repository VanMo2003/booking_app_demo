import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../feedback/domain/usecases/feedback_usecases.dart';
import '../../../payment/presentation/payment_flow.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../widgets/payment_countdown.dart';
import 'booking_detail_cubit.dart';

/// Chi tiết đơn — dùng chung cho khách (thanh toán, huỷ, đánh giá) và
/// nhân viên (xác nhận, thu tiền, hoàn tất, sửa, xoá).
@RoutePage()
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingDetailCubit>()..load(bookingId),
      child: _BookingDetailView(bookingId: bookingId),
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  const _BookingDetailView({required this.bookingId});

  final int bookingId;

  Future<void> _run(
    BuildContext context,
    BookingAction action, {
    required String success,
  }) async {
    final cubit = context.read<BookingDetailCubit>();
    await AppAction.run(context, () => cubit.perform(action), successMessage: success);
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: BookingStrings.cancelTitle,
      message: BookingStrings.cancelMessage,
      confirmLabel: BookingStrings.cancelBooking,
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await _run(context, BookingAction.cancel, success: BookingStrings.canceled);
    }
  }

  Future<void> _markPaid(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: BookingStrings.markPaidTitle,
      message: BookingStrings.markPaidMessage,
      confirmLabel: BookingStrings.markPaid,
    );
    if (confirmed && context.mounted) {
      await _run(context, BookingAction.markPaid, success: BookingStrings.markedPaid);
    }
  }

  Future<void> _complete(BuildContext context, Booking booking) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: BookingStrings.completeTitle,
      message: booking.isPaid
          ? BookingStrings.completeMessage
          : '${BookingStrings.completeUnpaidWarning}\n\n${BookingStrings.completeMessage}',
      confirmLabel: BookingStrings.completeBooking,
      icon: booking.isPaid ? null : Icons.warning_amber_rounded,
    );
    if (confirmed && context.mounted) {
      await _run(context, BookingAction.complete, success: BookingStrings.completed);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(BookingStrings.code(bookingId)),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      context.read<BookingDetailCubit>().delete,
      successMessage: BookingStrings.deleted,
    );
    if (result.isSuccess && context.mounted) await context.router.maybePop();
  }

  Future<void> _pay(BuildContext context, Booking booking) async {
    await PaymentFlow.payBooking(context, booking);
    if (context.mounted) await context.read<BookingDetailCubit>().refresh();
  }

  Future<void> _review(BuildContext context, Booking booking) async {
    final customerId = context.read<SessionCubit>().session?.customer?.id;
    if (customerId == null) return;
    final reviewed = await context.router.push<bool>(
      ReviewRoute(
        bookingId: booking.id,
        customerId: customerId,
        hotelName: booking.hotel?.name ?? '',
      ),
    );
    if (reviewed == true && context.mounted) {
      await context.read<BookingDetailCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<SessionCubit>().state.role;
    final backOffice = role?.isBackOffice ?? false;
    final canManage = role?.isManagerOrAbove ?? false;
    return BlocBuilder<BookingDetailCubit, BookingDetailState>(
      builder: (context, state) {
        final booking = state.booking.data;
        return AppPage(
          title: BookingStrings.code(bookingId),
          subtitle: booking?.status.label,
          actions: [
            if (backOffice && booking != null)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await context.router.push(BookingEditRoute(bookingId: bookingId));
                    if (context.mounted) await context.read<BookingDetailCubit>().refresh();
                  } else if (value == 'delete') {
                    await _delete(context);
                  }
                },
                itemBuilder: (_) => [
                  if (booking.status.isOpen)
                    const PopupMenuItem(value: 'edit', child: Text(BookingStrings.editBooking)),
                  if (canManage)
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        BookingStrings.deleteBooking,
                        style: AppTextStyles.body.colored(AppColors.danger),
                      ),
                    ),
                ],
              ),
          ],
          body: LoadStateView<Booking>(
            state: state.booking,
            onRetry: context.read<BookingDetailCubit>().refresh,
            builder: (context, booking) => RefreshIndicator(
              onRefresh: context.read<BookingDetailCubit>().refresh,
              child: _BookingBody(booking: booking, backOffice: backOffice),
            ),
          ),
          bottomBar: booking == null
              ? null
              : _actionBar(context, booking, backOffice: backOffice, busy: state.booking.status == ViewStatus.loading),
        );
      },
    );
  }

  Widget? _actionBar(
    BuildContext context,
    Booking booking, {
    required bool backOffice,
    required bool busy,
  }) {
    if (backOffice) {
      if (!booking.status.isOpen) return null;
      final primary = booking.status.canConfirm
          ? AppButton(
              label: BookingStrings.confirmBooking,
              icon: Icons.check_circle_outline_rounded,
              onPressed: () => _run(context, BookingAction.confirm, success: BookingStrings.confirmed),
            )
          : AppButton(
              label: BookingStrings.completeBooking,
              icon: Icons.logout_rounded,
              onPressed: () => _complete(context, booking),
            );
      return BottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!booking.isPaid) ...[
              AppButton.tonal(
                label: BookingStrings.markPaid,
                icon: Icons.payments_outlined,
                expand: true,
                onPressed: () => _markPaid(context),
              ),
              const Gap(AppSpacing.xs),
            ],
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.dangerOutline,
                    label: BookingStrings.cancelBooking,
                    onPressed: () => _cancel(context),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(child: primary),
              ],
            ),
          ],
        ),
      );
    }

    if (booking.status.isOpen) {
      return BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.dangerOutline,
                label: BookingStrings.cancelBooking,
                onPressed: () => _cancel(context),
              ),
            ),
            if (booking.canPayOnline) ...[
              const Gap(AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: booking.paymentStatus == PaymentStatus.pending
                      ? BookingStrings.payNow
                      : BookingStrings.payAgain,
                  icon: Icons.qr_code_2_rounded,
                  onPressed: () => _pay(context, booking),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final customerId = context.read<SessionCubit>().session?.customer?.id;
    if (booking.status == BookingStatus.completed && customerId != null) {
      final reviewed = getIt<IsBookingReviewed>()(customerId: customerId, bookingId: booking.id);
      return BottomActionBar(
        child: AppButton(
          label: reviewed ? BookingStrings.reviewed : BookingStrings.review,
          icon: reviewed ? Icons.check_rounded : Icons.star_outline_rounded,
          variant: reviewed ? AppButtonVariant.secondary : AppButtonVariant.primary,
          expand: true,
          onPressed: reviewed ? null : () => _review(context, booking),
        ),
      );
    }
    return null;
  }
}

class _BookingBody extends StatelessWidget {
  const _BookingBody({required this.booking, required this.backOffice});

  final Booking booking;
  final bool backOffice;

  @override
  Widget build(BuildContext context) {
    final hotel = booking.hotel;
    final customer = booking.customer;
    return ListView(
      padding: AppSpacing.page,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusBadge.booking(booking.status),
                        StatusBadge.payment(booking.paymentStatus),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(BookingStrings.total, style: AppTextStyles.caption),
                      Text(
                        Fmt.money(booking.totalAmount),
                        style: AppTextStyles.moneyLarge.colored(AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
              if (booking.canPayOnline && booking.paymentExpireAt != null) ...[
                const Gap(AppSpacing.sm),
                PaymentCountdown(expireAt: booking.paymentExpireAt!),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.md),
        if (!backOffice && hotel != null)
          _PartyCard(
            leading: AppNetworkImage(
              path: hotel.pathImage,
              width: 56,
              height: 56,
              borderRadius: AppRadius.smAll,
            ),
            title: hotel.name,
            lines: [hotel.address],
            phone: hotel.phone,
            callLabel: BookingStrings.callBranch,
          ),
        if (backOffice && customer != null)
          _PartyCard(
            leading: AppAvatar(name: customer.fullName, size: 48),
            title: customer.fullName,
            lines: [customer.phoneNumber, if (booking.createdAtDesk) BookingStrings.createdAtDesk],
            phone: customer.phoneNumber,
            callLabel: BookingStrings.callGuest,
          ),
        const Gap(AppSpacing.md),
        const SectionHeader(title: BookingStrings.stay),
        const Gap(AppSpacing.xs),
        AppCard(
          child: Row(
            children: [
              Expanded(child: _DateBlock(label: 'Nhận phòng', date: booking.checkinDate)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  AppStrings.nights(booking.nights),
                  style: AppTextStyles.captionStrong.colored(AppColors.primaryDark),
                ),
              ),
              Expanded(
                child: _DateBlock(label: 'Trả phòng', date: booking.checkoutDate, alignEnd: true),
              ),
            ],
          ),
        ),
        if (booking.rooms.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          SectionHeader(title: '${BookingStrings.roomsBooked} (${booking.rooms.length})'),
          const Gap(AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < booking.rooms.length; i++) ...[
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        AppNetworkImage(
                          path: booking.rooms[i].pathImage,
                          width: 44,
                          height: 44,
                          borderRadius: AppRadius.smAll,
                          placeholderIcon: Icons.bed_rounded,
                        ),
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phòng ${booking.rooms[i].roomNumber}', style: AppTextStyles.bodyStrong),
                              Text(
                                [
                                  if (booking.rooms[i].roomTypeName.isNotEmpty) booking.rooms[i].roomTypeName,
                                  AppStrings.guests(booking.rooms[i].capacity),
                                ].join(' · '),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (booking.services.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          SectionHeader(title: '${BookingStrings.servicesBooked} (${booking.services.length})'),
          const Gap(AppSpacing.xs),
          AppCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final service in booking.services)
                  SoftTag(label: service.name, icon: Icons.room_service_outlined),
              ],
            ),
          ),
        ],
        const Gap(AppSpacing.md),
        const SectionHeader(title: BookingStrings.payment),
        const Gap(AppSpacing.xs),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(label: BookingStrings.paymentMethod, value: booking.paymentMethod.label),
              InfoRow(
                label: BookingStrings.paymentStatus,
                value: booking.paymentStatus.label,
                valueWidget: StatusBadge.payment(booking.paymentStatus, dense: true),
              ),
              if (booking.paidAt != null)
                InfoRow(label: BookingStrings.paidAt, value: Fmt.dateTime(booking.paidAt)),
              const Divider(),
              InfoRow(
                label: BookingStrings.total,
                value: Fmt.money(booking.totalAmount),
                valueStyle: AppTextStyles.money.colored(AppColors.primaryDark),
              ),
            ],
          ),
        ),
        if ((booking.note ?? '').isNotEmpty) ...[
          const Gap(AppSpacing.md),
          const SectionHeader(title: BookingStrings.note),
          const Gap(AppSpacing.xs),
          AppCard(child: Text(booking.note!, style: AppTextStyles.body)),
        ],
        if (booking.createdAt != null) ...[
          const Gap(AppSpacing.md),
          Text(
            '${BookingStrings.createdAt} ${Fmt.dateTime(booking.createdAt)}',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.leading,
    required this.title,
    required this.lines,
    required this.phone,
    required this.callLabel,
  });

  final Widget leading;
  final String title;
  final List<String> lines;
  final String phone;
  final String callLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          leading,
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                for (final line in lines.where((l) => l.isNotEmpty))
                  Text(line, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
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

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.label, required this.date, this.alignEnd = false});

  final String label;
  final DateTime date;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const Gap(2),
        Text(Fmt.weekdayDate(date), style: AppTextStyles.subtitle),
        Text(Fmt.date(date), style: AppTextStyles.caption),
      ],
    );
  }
}
