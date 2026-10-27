import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../booking/domain/usecases/booking_usecases.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';

@injectable
class ReceivablesCubit extends LoadCubit<List<Receivable>> {
  ReceivablesCubit(this._reports, this._changeStatus);

  final ReportRepository _reports;
  final ChangeBookingStatus _changeStatus;
  late ReportScope _scope;

  Future<void> start(ReportScope scope) {
    _scope = scope;
    return load();
  }

  @override
  Future<void> load() => guard(() => _reports.receivables(_scope));

  /// Ghi nhận đã thu tiền đơn [bookingId] rồi tải lại danh sách.
  Future<ActionResult<void>> markPaid(int bookingId) => runAction(() async {
        await _changeStatus(bookingId, BookingAction.markPaid);
        await load();
      });
}

/// Đơn đã trả phòng nhưng chưa ghi nhận thanh toán, của một cơ sở hoặc cả
/// chuỗi; mở từ cảnh báo trên màn Tổng quan.
@RoutePage()
class ReceivablesScreen extends StatelessWidget {
  const ReceivablesScreen({super.key, this.hotelId, this.hotelChainId});

  final int? hotelId;
  final int? hotelChainId;

  @override
  Widget build(BuildContext context) {
    final ReportScope scope =
        hotelId != null ? BranchReportScope(hotelId!) : ChainReportScope(hotelChainId ?? 0);
    return BlocProvider(
      create: (_) => getIt<ReceivablesCubit>()..start(scope),
      child: _ReceivablesView(isChain: hotelId == null),
    );
  }
}

class _ReceivablesView extends StatelessWidget {
  const _ReceivablesView({required this.isChain});

  final bool isChain;

  Future<void> _markPaid(BuildContext context, Receivable row) async {
    final cubit = context.read<ReceivablesCubit>();
    final confirmed = await AppDialogs.confirm(
      context,
      title: BookingStrings.markPaidTitle,
      message: ReportStrings.receivableConfirm(row.customerName, Fmt.money(row.totalAmount)),
      confirmLabel: BookingStrings.markPaid,
    );
    if (!confirmed || !context.mounted) return;
    await AppAction.run(context, () => cubit.markPaid(row.bookingId), successMessage: BookingStrings.markedPaid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceivablesCubit, LoadState<List<Receivable>>>(
      builder: (context, state) {
        final cubit = context.read<ReceivablesCubit>();
        return AppPage(
          title: ReportStrings.receivablesTitle,
          body: LoadStateView<List<Receivable>>(
            state: state,
            onRetry: cubit.load,
            isEmpty: (rows) => rows.isEmpty,
            empty: const AppEmptyView(
              title: ReportStrings.receivablesEmpty,
              message: ReportStrings.receivablesEmptyNote,
              icon: Icons.task_alt_rounded,
              showButton: false,
            ),
            builder: (context, rows) => RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ReportStrings.receivablesTotal(rows.length), style: AppTextStyles.caption),
                        const Gap(4),
                        Text(
                          Fmt.money(rows.fold<double>(0, (sum, row) => sum + row.totalAmount)),
                          style: AppTextStyles.moneyLarge.colored(AppColors.danger),
                        ),
                        const Gap(AppSpacing.xs),
                        Text(ReportStrings.receivablesNote, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  for (final row in rows) ...[
                    const Gap(AppSpacing.sm),
                    _ReceivableCard(
                      row: row,
                      showHotel: isChain,
                      onOpen: () => context.rootRouter.push(BookingDetailRoute(bookingId: row.bookingId)),
                      onMarkPaid: () => _markPaid(context, row),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReceivableCard extends StatelessWidget {
  const _ReceivableCard({
    required this.row,
    required this.showHotel,
    required this.onOpen,
    required this.onMarkPaid,
  });

  final Receivable row;
  final bool showHotel;
  final VoidCallback onOpen;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final late = row.daysOverdue > 7;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.customerName.isEmpty ? ReportStrings.bookingNumber(row.bookingId) : row.customerName,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(Fmt.money(row.totalAmount), style: AppTextStyles.tabular.weight(FontWeight.w600)),
            ],
          ),
          const Gap(2),
          Text(
            [
              ReportStrings.bookingNumber(row.bookingId),
              if (row.phoneNumber.isNotEmpty) row.phoneNumber,
              PaymentMethod.parse(row.paymentMethod).label,
              if (showHotel) row.hotelName,
            ].join(' · '),
            style: AppTextStyles.caption,
          ),
          const Gap(2),
          Text(
            ReportStrings.receivableDue(Fmt.date(row.checkoutDate), row.daysOverdue),
            style: AppTextStyles.caption.colored(late ? AppColors.danger : AppColors.inkSecondary),
          ),
          const Gap(AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: ReportStrings.openBooking,
                  size: AppButtonSize.medium,
                  onPressed: onOpen,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: BookingStrings.markPaid,
                  icon: Icons.payments_outlined,
                  size: AppButtonSize.medium,
                  onPressed: onMarkPaid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
