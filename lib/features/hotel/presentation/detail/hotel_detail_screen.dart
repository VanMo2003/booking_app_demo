import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/session/auth_gate.dart';
import '../../../chat/presentation/chat_entry.dart';
import '../../../dish/presentation/widgets/hotel_menu_preview.dart';
import '../../../favorite/presentation/favorite_button.dart';
import '../../../room/presentation/widgets/room_tile.dart';
import '../../domain/entities/hotel.dart';
import '../widgets/hotel_card.dart';
import 'hotel_detail_cubit.dart';

/// Chi tiết cơ sở — công khai. Chọn ngày để xem phòng nào còn trống.
@RoutePage()
class HotelDetailScreen extends StatelessWidget {
  const HotelDetailScreen({
    super.key,
    required this.hotelId,
    this.checkin,
    this.checkout,
  });

  final int hotelId;
  final DateTime? checkin;
  final DateTime? checkout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HotelDetailCubit>()
        ..load(hotelId, checkin: checkin, checkout: checkout),
      child: const _HotelDetailView(),
    );
  }
}

class _HotelDetailView extends StatelessWidget {
  const _HotelDetailView();

  Future<void> _pickDates(BuildContext context, HotelDetailState state) async {
    final range = await showStayDatesPicker(
      context,
      checkin: state.checkin,
      checkout: state.checkout,
    );
    if (range != null && context.mounted) {
      await context.read<HotelDetailCubit>().changeDates(range);
    }
  }

  Future<void> _book(
    BuildContext context,
    HotelDetail detail,
    HotelDetailState state, {
    int? roomId,
  }) async {
    if (!state.hasDates) {
      await _pickDates(context, state);
      return;
    }
    final customer = await context.ensureCustomer();
    if (customer == null || !context.mounted) return;
    await context.router.push(
      BookingCreateRoute(
        hotelId: detail.id,
        checkin: state.checkin!,
        checkout: state.checkout!,
        preselectedRoomIds: roomId == null ? const [] : [roomId],
      ),
    );
    if (context.mounted) await context.read<HotelDetailCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailCubit, HotelDetailState>(
      builder: (context, state) {
        final detail = state.detail.data;
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: state.detail.isFailure
                ? AppFailureView.fromState(
                    state.detail,
                    onRetry: context.read<HotelDetailCubit>().retry,
                  )
                : const AppLoadingView(),
          );
        }
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: context.read<HotelDetailCubit>().refresh,
            child: CustomScrollView(
              slivers: [
                _GalleryAppBar(detail: detail),
                SliverToBoxAdapter(
                  child: _HotelBody(
                    detail: detail,
                    state: state,
                    onPickDates: () => _pickDates(context, state),
                    onOpenRoom: (roomId) => context.router.push(
                      RoomDetailRoute(
                        roomId: roomId,
                        hotelId: detail.id,
                        checkin: state.checkin,
                        checkout: state.checkout,
                      ),
                    ),
                    onBookRoom: (roomId) => _book(context, detail, state, roomId: roomId),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: detail.hotel.active
              ? _BookingBar(
                  detail: detail,
                  state: state,
                  onPressed: () => _book(context, detail, state),
                )
              : null,
        );
      },
    );
  }
}

class _GalleryAppBar extends StatelessWidget {
  const _GalleryAppBar({required this.detail});

  final HotelDetail detail;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleIconButton(
          icon: Icons.arrow_back_rounded,
          background: AppColors.surface.withValues(alpha: 0.94),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      actions: [
        FavoriteButton(hotel: favoriteOf(detail.hotel)),
        const Gap(AppSpacing.xs),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsed = constraints.maxHeight <=
              kToolbarHeight + MediaQuery.paddingOf(context).top + 12;
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(start: 64, bottom: 16, end: 64),
            title: collapsed
                ? Text(
                    detail.hotel.name,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            background: ImageCarousel(paths: detail.gallery),
          );
        },
      ),
    );
  }
}

class _HotelBody extends StatelessWidget {
  const _HotelBody({
    required this.detail,
    required this.state,
    required this.onPickDates,
    required this.onOpenRoom,
    required this.onBookRoom,
  });

  final HotelDetail detail;
  final HotelDetailState state;
  final VoidCallback onPickDates;
  final ValueChanged<int> onOpenRoom;
  final ValueChanged<int> onBookRoom;

  @override
  Widget build(BuildContext context) {
    final hotel = detail.hotel;
    final amenities = detail.commonAmenities;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hotel.name, style: AppTextStyles.headline),
          const Gap(6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hotel.category.isNotEmpty) SoftTag(label: hotel.category),
              if (hotel.rating > 0) RatingStars(rating: hotel.rating),
            ],
          ),
          const Gap(AppSpacing.sm),
          IconText(
            icon: Icons.location_on_outlined,
            text: hotel.address,
            maxLines: 2,
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: hotel.phone.isEmpty
                    ? const SizedBox.shrink()
                    : IconText(icon: Icons.call_outlined, text: hotel.phone),
              ),
              if (hotel.phone.isNotEmpty)
                AppButton.text(
                  label: AppStrings.call,
                  size: AppButtonSize.small,
                  icon: Icons.phone_in_talk_outlined,
                  onPressed: () => ExternalActions.call(hotel.phone),
                ),
              // Hỏi phòng, giá, dịch vụ — cả đội ngũ cơ sở nhận được tin.
              AppButton.text(
                label: ChatStrings.messageAction,
                size: AppButtonSize.small,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => context.openHotelChat(detail.id),
              ),
            ],
          ),
          if (!hotel.active) ...[
            const Gap(AppSpacing.sm),
            const _Banner(text: ExploreStrings.branchClosed),
          ],
          const Gap(AppSpacing.lg),
          StayDatesCard(
            checkin: state.checkin,
            checkout: state.checkout,
            onChanged: context.read<HotelDetailCubit>().changeDates,
          ),
          if (hotel.description.isNotEmpty) ...[
            const Gap(AppSpacing.xl),
            const SectionHeader(title: ExploreStrings.about),
            const Gap(AppSpacing.xs),
            ExpandableText(hotel.description),
          ],
          if (amenities.isNotEmpty) ...[
            const Gap(AppSpacing.xl),
            const SectionHeader(title: ExploreStrings.amenities),
            const Gap(AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amenity in amenities)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(color: AppColors.lineSoft),
                    ),
                    child: IconText(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.primary,
                      text: amenity.name,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
              ],
            ),
          ],
          if (hotel.services.isNotEmpty) ...[
            const Gap(AppSpacing.xl),
            const SectionHeader(title: ExploreStrings.services),
            const Gap(AppSpacing.xs),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < hotel.services.length; i++) ...[
                    if (i > 0) const Divider(),
                    InfoRow(
                      icon: Icons.room_service_outlined,
                      label: hotel.services[i].name,
                      value: Fmt.money(hotel.services[i].unitPrice),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ],
                ],
              ),
            ),
          ],
          HotelMenuPreview(hotelId: detail.id, hotelName: hotel.name),
          const Gap(AppSpacing.xl),
          SectionHeader(
            title: ExploreStrings.rooms,
            subtitle: state.hasDates
                ? ExploreStrings.availableRooms(detail.availableRooms.length)
                : ExploreStrings.pickDatesHint,
            actionLabel: state.hasDates ? null : ExploreStrings.pickDates,
            onAction: state.hasDates ? null : onPickDates,
          ),
          const Gap(AppSpacing.sm),
          if (detail.rooms.isEmpty)
            Text(ExploreStrings.noRooms, style: AppTextStyles.bodySmall)
          else
            for (final room in detail.rooms) ...[
              RoomTile(
                room: room,
                showStatus: state.hasDates,
                onTap: () => onOpenRoom(room.id),
                trailing: state.hasDates && room.status.isBookable && hotel.active
                    ? AppButton.tonal(
                        label: ExploreStrings.book,
                        size: AppButtonSize.small,
                        onPressed: () => onBookRoom(room.id),
                      )
                    : null,
              ),
              const Gap(AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({
    required this.detail,
    required this.state,
    required this.onPressed,
  });

  final HotelDetail detail;
  final HotelDetailState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final prices = detail.rooms.map((room) => room.price);
    final lowest = prices.isEmpty ? null : prices.reduce(math.min);
    final available = detail.availableRooms.length;
    return BottomActionBar(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.hasDates
                      ? ExploreStrings.availableRooms(available)
                      : ExploreStrings.pickDatesHint,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lowest != null)
                  PriceText(lowest, unit: AppStrings.perNight, color: AppColors.primaryDark),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          AppButton(
            label: state.hasDates ? ExploreStrings.bookNow : ExploreStrings.pickDates,
            icon: state.hasDates ? null : Icons.calendar_month_outlined,
            onPressed: state.hasDates && available == 0 ? null : onPressed,
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadius.smAll,
      ),
      child: IconText(
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.warning,
        text: text,
        maxLines: 2,
        style: AppTextStyles.bodySmall.colored(AppColors.warning),
      ),
    );
  }
}
