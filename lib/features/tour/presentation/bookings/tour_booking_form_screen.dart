import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/discover_strings.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/tour_booking_models.dart';
import '../../domain/entities/tour.dart';
import '../../domain/usecases/tour_booking_usecases.dart';
import '../../domain/usecases/tour_usecases.dart';
import '../../../voucher/data/voucher_repository.dart';
import '../../../voucher/domain/entities/voucher.dart';
import '../../../voucher/presentation/voucher_widgets.dart';

/// Khách đặt tour trong ứng dụng: chọn ngày đi, số khách và — với tour kèm phòng — các phòng
/// của gói còn trống đêm đó (nhận phòng đúng ngày đi tour). Đặt xong mở chi tiết đơn tour.
@RoutePage()
class TourBookingFormScreen extends StatefulWidget {
  const TourBookingFormScreen({super.key, required this.tour, this.hotelName});

  final Tour tour;
  final String? hotelName;

  @override
  State<TourBookingFormScreen> createState() => _TourBookingFormScreenState();
}

class _TourBookingFormScreenState extends State<TourBookingFormScreen> {
  static const _maxPerOrder = 50;

  late DateTime _date = DateOnly.today().add(const Duration(days: 1));
  late int _adults = math.min(2, _limit);
  int _children = 0;
  final _selected = <int>{};
  final _note = TextEditingController();
  final _voucherCode = TextEditingController();

  /// Mã đã áp dụng (đã kiểm tra với BE cho đúng số khách hiện tại).
  VoucherCheck? _voucher;
  bool _checkingVoucher = false;
  LoadState<TourStay> _stay = const LoadState();
  bool _saving = false;

  Tour get _tour => widget.tour;

  int get _limit => math.min(_maxPerOrder, _tour.maxGuests ?? _maxPerOrder);

  List<TourRoom> get _chosen => (_stay.data?.rooms ?? const <TourRoom>[])
      .where((room) => _selected.contains(room.roomId))
      .toList();

  int get _nights => _stay.data?.nights ?? _tour.stayNights;

  int get _beds => _chosen.fold(0, (sum, room) => sum + room.capacity);

  int get _guests => _adults + _children;

  double get _adultAmount => _tour.salePrice * _adults;

  double get _childAmount => _tour.childPayPrice * _children;

  double get _discount => _voucher?.valid == true ? _voucher!.discount : 0;

  double get _tourAmount => _adultAmount + _childAmount - _discount;

  double get _roomAmount => _chosen.fold(0.0, (sum, room) => sum + room.price) * _nights;

  @override
  void initState() {
    super.initState();
    _loadStay();
  }

  @override
  void dispose() {
    _note.dispose();
    _voucherCode.dispose();
    super.dispose();
  }

  void _setGuests({int? adults, int? children}) {
    setState(() {
      _adults = adults ?? _adults;
      _children = children ?? _children;
    });
    // Giảm theo % đổi theo số khách: kiểm tra lại mã đang dùng.
    if (_voucher?.valid == true) _applyVoucher(_voucher!.code);
  }

  Future<void> _applyVoucher([String? code]) async {
    final text = (code ?? _voucherCode.text).trim();
    if (text.isEmpty) return;
    _voucherCode.text = text.toUpperCase();
    setState(() => _checkingVoucher = true);
    try {
      final check = await getIt<VoucherRepository>()
          .check(code: text, tourId: _tour.id, guests: _guests, children: _children);
      if (!mounted) return;
      setState(() => _voucher = check);
      if (!check.valid) AppToast.error(context, check.message);
    } catch (error) {
      if (mounted) AppToast.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _checkingVoucher = false);
    }
  }

  void _removeVoucher() => setState(() {
        _voucher = null;
        _voucherCode.clear();
      });

  Future<void> _pickVoucher() async {
    final List<Voucher> vouchers;
    try {
      vouchers = await getIt<VoucherRepository>().available(hotelId: _tour.hotelId);
    } catch (error) {
      if (mounted) AppToast.error(context, error.toString());
      return;
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<Voucher>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7),
          child: vouchers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(DiscoverStrings.voucherNoneHere, textAlign: TextAlign.center),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: vouchers.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                  itemBuilder: (_, i) => VoucherTicket(
                    voucher: vouchers[i],
                    selected: _voucher?.code == vouchers[i].code,
                    onTap: () => Navigator.of(sheetContext).pop(vouchers[i]),
                  ),
                ),
        ),
      ),
    );
    if (picked != null) await _applyVoucher(picked.code);
  }

  Future<void> _loadStay() async {
    if (!_tour.withRooms) return;
    setState(() => _stay = _stay.toLoading());
    try {
      final stay = await getIt<GetTourStay>()(_tour.id, _date);
      if (!mounted) return;
      setState(() {
        _stay = _stay.toSuccess(stay);
        // Phòng đã chọn mà ngày mới không còn trống thì bỏ chọn.
        _selected.retainWhere((id) => stay.rooms.any((room) => room.roomId == id));
      });
    } catch (error) {
      if (mounted) setState(() => _stay = _stay.toError(error));
    }
  }

  void _setDate(DateTime date) {
    setState(() => _date = date);
    _loadStay();
  }

  Future<void> _submit() async {
    if (_tour.withRooms) {
      if (_chosen.isEmpty) {
        AppToast.error(context, TourBookingStrings.pickRoom);
        return;
      }
      if (_beds < _guests) {
        AppToast.error(context, TourBookingStrings.needMoreRooms(_guests));
        return;
      }
    }
    setState(() => _saving = true);
    final result = await AppAction.run(
      context,
      () => runAction(
        () => getIt<PlaceTourBooking>()(
          TourBookingRequest(
            tourId: _tour.id,
            tourDate: _date,
            guests: _guests,
            children: _children,
            voucherCode: _voucher?.valid == true ? _voucher!.code : null,
            roomIds: _chosen.map((room) => room.roomId).toList(),
            note: _note.text,
          ),
        ),
      ),
      successMessage: TourBookingStrings.placed,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final booking = result.value;
    if (booking != null) {
      await context.router.replace(TourBookingDetailRoute(bookingId: booking.id));
    } else if (_tour.withRooms) {
      // Phòng vừa có người khác đặt chẳng hạn — tải lại để khách chọn lại.
      await _loadStay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateOnly.today();
    return AppPage(
      title: TourBookingStrings.formTitle,
      subtitle: _tour.name,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AppNetworkImage(
                  path: _tour.pathImage,
                  width: 64,
                  height: 64,
                  borderRadius: AppRadius.smAll,
                  placeholderIcon: Icons.tour_outlined,
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tour.name, style: AppTextStyles.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (widget.hotelName != null) Text(widget.hotelName!, style: AppTextStyles.caption),
                      if (_tour.departure != null)
                        IconText(icon: Icons.schedule_rounded, iconSize: 14, text: _tour.departure!, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                PriceText(_tour.salePrice, unit: TourStrings.perGuest),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          const GroupLabel(TourBookingStrings.dateAndGuests),
          AppDateField(
            label: TourBookingStrings.date,
            value: _date,
            firstDate: today,
            lastDate: today.add(const Duration(days: 365)),
            onChanged: _setDate,
            enabled: !_saving,
          ),
          const Gap(AppSpacing.sm),
          _GuestCounter(
            label: DiscoverStrings.adults,
            icon: Icons.person_rounded,
            value: _adults,
            min: 1,
            max: _limit - _children,
            onChanged: _saving ? null : (value) => _setGuests(adults: value),
          ),
          const Gap(AppSpacing.xs),
          _GuestCounter(
            label: DiscoverStrings.children,
            hint: DiscoverStrings.childrenHint,
            icon: Icons.child_care_rounded,
            value: _children,
            min: 0,
            max: _limit - _adults,
            onChanged: _saving ? null : (value) => _setGuests(children: value),
          ),
          if (_tour.withRooms) ...[
            const Gap(AppSpacing.lg),
            const GroupLabel(TourBookingStrings.chooseRooms),
            _rooms(),
          ],
          const Gap(AppSpacing.lg),
          AppTextField(
            controller: _note,
            label: TourBookingStrings.noteForHotel,
            hint: TourBookingStrings.notePlaceholder,
            minLines: 1,
            maxLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
          ),
          const Gap(AppSpacing.lg),
          const GroupLabel(DiscoverStrings.voucher),
          _voucherField(),
          const Gap(AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                InfoRow(
                  label: DiscoverStrings.adultPart(_adults),
                  value: Fmt.money(_adultAmount),
                ),
                if (_children > 0)
                  InfoRow(
                    label: DiscoverStrings.childPart(_children),
                    value: Fmt.money(_childAmount),
                  ),
                if (_discount > 0)
                  InfoRow(
                    label: DiscoverStrings.voucherLine(_voucher!.code),
                    value: '-${Fmt.money(_discount)}',
                    valueStyle: AppTextStyles.bodyStrong.colored(AppColors.success),
                  ),
                if (_tour.withRooms)
                  InfoRow(label: TourBookingStrings.roomPart(_nights), value: Fmt.money(_roomAmount)),
                const Divider(),
                InfoRow(
                  label: TourBookingStrings.total,
                  value: Fmt.money(_tourAmount + _roomAmount),
                  valueStyle: AppTextStyles.money.colored(AppColors.primaryDark),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          const NoticeBanner(text: TourBookingStrings.formNotice, icon: Icons.info_outline_rounded),
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: '${TourBookingStrings.formTitle} · ${Fmt.money(_tourAmount + _roomAmount)}',
          icon: Icons.check_circle_outline_rounded,
          expand: true,
          loading: _saving,
          onPressed: _stay.isLoading ? null : _submit,
        ),
      ),
    );
  }

  Widget _voucherField() {
    final applied = _voucher?.valid == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _voucherCode,
                hint: DiscoverStrings.voucherHint,
                enabled: !_saving && !applied,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: Icons.local_offer_outlined,
                onSubmitted: (_) => _applyVoucher(),
              ),
            ),
            const Gap(AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: applied
                  ? TextButton(onPressed: _saving ? null : _removeVoucher, child: const Text(DiscoverStrings.voucherRemove))
                  : FilledButton.tonal(
                      onPressed: _saving || _checkingVoucher ? null : _applyVoucher,
                      child: _checkingVoucher
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(DiscoverStrings.voucherApply),
                    ),
            ),
          ],
        ),
        if (applied)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DiscoverStrings.voucherApplied(_voucher!.code, Fmt.money(_voucher!.discount)),
              style: AppTextStyles.caption.colored(AppColors.success),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _saving ? null : _pickVoucher,
            icon: const Icon(Icons.confirmation_number_outlined, size: 18),
            label: const Text(DiscoverStrings.voucherPick),
          ),
        ),
      ],
    );
  }

  Widget _rooms() {
    final stay = _stay.data;
    if (_stay.isLoading && stay == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_stay.isFailure) {
      return AppErrorView(message: _stay.error, onRetry: _loadStay, compact: true, showImage: false);
    }
    if (stay == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TourBookingStrings.stayRange(Fmt.weekdayDate(stay.checkin), Fmt.weekdayDate(stay.checkout), stay.nights),
          style: AppTextStyles.caption,
        ),
        const Gap(AppSpacing.xs),
        if (stay.rooms.isEmpty)
          const NoticeBanner(text: TourBookingStrings.noFreeRooms, icon: Icons.event_busy_rounded)
        else ...[
          for (final room in stay.rooms) ...[
            SelectableCard(
              selected: _selected.contains(room.roomId),
              enabled: !_saving,
              onTap: () => setState(() {
                if (!_selected.remove(room.roomId)) _selected.add(room.roomId);
              }),
              child: Row(
                children: [
                  AppNetworkImage(
                    path: room.pathImage,
                    width: 48,
                    height: 48,
                    borderRadius: AppRadius.smAll,
                    placeholderIcon: Icons.bed_rounded,
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phòng ${room.roomNumber} · ${room.roomTypeName}', style: AppTextStyles.bodyStrong),
                        Text(TourStrings.capacity(room.capacity), style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  PriceText(room.price, unit: TourStrings.perNight),
                ],
              ),
            ),
            const Gap(AppSpacing.xs),
          ],
          if (_chosen.isNotEmpty)
            Text(
              _beds >= _guests ? TourBookingStrings.beds(_beds, _guests) : TourBookingStrings.needMoreRooms(_guests),
              style: AppTextStyles.caption.colored(_beds >= _guests ? AppColors.success : AppColors.danger),
            ),
        ],
      ],
    );
  }
}

/// Một loại khách (người lớn / trẻ em): nút trừ / cộng trong giới hạn của tour.
class _GuestCounter extends StatelessWidget {
  const _GuestCounter({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.inkSecondary),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body),
                if (hint != null) Text(hint!, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: onChanged == null || value <= min ? null : () => onChanged!(value - 1),
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 32,
            child: Text('$value', style: AppTextStyles.subtitle, textAlign: TextAlign.center),
          ),
          IconButton(
            onPressed: onChanged == null || value >= max ? null : () => onChanged!(value + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}
