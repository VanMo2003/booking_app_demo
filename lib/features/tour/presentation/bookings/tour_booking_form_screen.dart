import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/tour_booking_models.dart';
import '../../domain/entities/tour.dart';
import '../../domain/usecases/tour_booking_usecases.dart';
import '../../domain/usecases/tour_usecases.dart';

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
  late int _guests = math.min(2, _limit);
  final _selected = <int>{};
  final _note = TextEditingController();
  LoadState<TourStay> _stay = const LoadState();
  bool _saving = false;

  Tour get _tour => widget.tour;

  int get _limit => math.min(_maxPerOrder, _tour.maxGuests ?? _maxPerOrder);

  List<TourRoom> get _chosen => (_stay.data?.rooms ?? const <TourRoom>[])
      .where((room) => _selected.contains(room.roomId))
      .toList();

  int get _nights => _stay.data?.nights ?? _tour.stayNights;

  int get _beds => _chosen.fold(0, (sum, room) => sum + room.capacity);

  double get _tourAmount => _tour.price * _guests;

  double get _roomAmount => _chosen.fold(0.0, (sum, room) => sum + room.price) * _nights;

  @override
  void initState() {
    super.initState();
    _loadStay();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
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
                PriceText(_tour.price, unit: TourStrings.perGuest),
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
            value: _guests,
            max: _limit,
            onChanged: _saving ? null : (value) => setState(() => _guests = value),
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
          const Gap(AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                InfoRow(
                  label: TourBookingStrings.tourPart(Fmt.money(_tour.price), _guests),
                  value: Fmt.money(_tourAmount),
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

/// Số khách: nút trừ / cộng trong giới hạn của tour.
class _GuestCounter extends StatelessWidget {
  const _GuestCounter({required this.value, required this.max, required this.onChanged});

  final int value;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.groups_outlined, size: 20, color: AppColors.inkSecondary),
          const Gap(AppSpacing.sm),
          Expanded(child: Text(TourBookingStrings.guestCount, style: AppTextStyles.body)),
          IconButton(
            onPressed: onChanged == null || value <= 1 ? null : () => onChanged!(value - 1),
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
