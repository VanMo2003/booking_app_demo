import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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
import '../../../../core/text/explore_strings.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/domain/usecases/booking_usecases.dart';
import '../../../booking/presentation/widgets/booking_card.dart';
import '../../data/models/customer_models.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Đơn của một khách tại cơ sở (lọc từ danh sách đơn của cơ sở).
@injectable
class CustomerBookingsCubit extends LoadCubit<List<Booking>> {
  CustomerBookingsCubit(this._getBookings);

  final GetBranchBookings _getBookings;
  late int _hotelId;
  late int _customerId;

  Future<void> start({required int hotelId, required int customerId}) {
    _hotelId = hotelId;
    _customerId = customerId;
    return load();
  }

  @override
  Future<void> load() => guard(
        () async => (await _getBookings(_hotelId))
            .where((booking) => booking.customer?.id == _customerId)
            .toList(),
      );
}

@RoutePage()
class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({
    super.key,
    required this.hotelId,
    required this.customer,
  });

  final int hotelId;
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomerBookingsCubit>()
        ..start(hotelId: hotelId, customerId: customer.id),
      child: _CustomerDetailView(customer: customer),
    );
  }
}

class _CustomerDetailView extends StatefulWidget {
  const _CustomerDetailView({required this.customer});

  final Customer customer;

  @override
  State<_CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<_CustomerDetailView> {
  late Customer _customer = widget.customer;

  Future<void> _edit() async {
    final updated = await AppDialogs.sheet<Customer>(
      context,
      title: WorkspaceStrings.editCustomer,
      builder: (_) => _CustomerForm(customer: _customer),
    );
    if (updated == null || !mounted) return;
    setState(() => _customer = updated);
    AppToast.success(context, WorkspaceStrings.customerSaved);
  }

  Future<void> _openBooking(Booking booking) async {
    await context.router.push(BookingDetailRoute(bookingId: booking.id));
    if (mounted) await context.read<CustomerBookingsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    final walkIn = customer.isWalkIn;
    final details = [customer.gender, customer.hometown]
        .where((part) => part.isNotEmpty)
        .join(' · ');
    return BlocBuilder<CustomerBookingsCubit, LoadState<List<Booking>>>(
      builder: (context, state) {
        final cubit = context.read<CustomerBookingsCubit>();
        final bookings = state.data ?? const <Booking>[];
        final spend = bookings
            .where((booking) => booking.status == BookingStatus.completed)
            .fold<double>(0, (sum, booking) => sum + booking.totalAmount);
        return AppPage(
          title: WorkspaceStrings.customerDetailTitle,
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          AppAvatar(
                            name: customer.fullName,
                            imagePath: customer.pathImage,
                            size: 56,
                            tone: walkIn ? StatusTone.neutral : StatusTone.brand,
                          ),
                          const Gap(AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.fullName, style: AppTextStyles.title),
                                const Gap(2),
                                IconText(icon: Icons.phone_outlined, text: customer.phoneNumber),
                                if (details.isNotEmpty) ...[
                                  const Gap(2),
                                  IconText(icon: Icons.badge_outlined, text: details),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.sm),
                      Row(
                        children: [
                          SoftTag(
                            label: walkIn
                                ? WorkspaceStrings.walkInBadge
                                : WorkspaceStrings.accountBadge,
                            tone: walkIn ? StatusTone.neutral : StatusTone.brand,
                          ),
                          const Spacer(),
                          AppButton.secondary(
                            label: AppStrings.call,
                            icon: Icons.call_outlined,
                            size: AppButtonSize.small,
                            onPressed: customer.phoneNumber.isEmpty
                                ? null
                                : () => ExternalActions.call(customer.phoneNumber),
                          ),
                          const Gap(AppSpacing.xs),
                          AppButton.tonal(
                            label: AppStrings.edit,
                            icon: Icons.edit_outlined,
                            size: AppButtonSize.small,
                            onPressed: _edit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: ReportStrings.totalBookings,
                        value: state.hasData ? Fmt.number(bookings.length) : '–',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: StatCard(
                        label: WorkspaceStrings.customerSpend,
                        value: state.hasData ? Fmt.moneyCompact(spend) : '–',
                        icon: Icons.payments_outlined,
                        tone: StatusTone.success,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),
                const SectionHeader(title: WorkspaceStrings.bookingHistory),
                const Gap(AppSpacing.sm),
                if (!state.hasData)
                  state.isFailure
                      ? AppErrorView(message: state.error!, onRetry: cubit.load)
                      : const AppLoadingView()
                else if (bookings.isEmpty)
                  Text(WorkspaceStrings.customerBookingsEmpty, style: AppTextStyles.bodySmall)
                else
                  for (final booking in bookings) ...[
                    BookingCard(
                      booking: booking,
                      view: BookingCardView.desk,
                      onTap: () => _openBooking(booking),
                    ),
                    const Gap(AppSpacing.sm),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomerForm extends StatefulWidget {
  const _CustomerForm({required this.customer});

  final Customer customer;

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _form = GlobalKey<FormState>();
  late final _fullName = TextEditingController(text: widget.customer.fullName);
  late final _phone = TextEditingController(text: widget.customer.phoneNumber);
  late String? _gender = widget.customer.gender.isEmpty ? null : widget.customer.gender;
  late String? _hometown = widget.customer.hometown.isEmpty ? null : widget.customer.hometown;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<UpdateCustomer>()(
        widget.customer.id,
        CustomerRequest(
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          gender: _gender ?? '',
          hometown: _hometown ?? '',
          pathImage: widget.customer.pathImage,
        ),
      ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(result.value);
    } else {
      setState(() {
        _saving = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          AppTextField(
            controller: _phone,
            label: ExploreStrings.phone,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            validator: Validators.phone,
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
          if (_error != null) ...[
            const Gap(AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.lg),
          AppButton(label: AppStrings.save, expand: true, loading: _saving, onPressed: _submit),
        ],
      ),
    );
  }
}
