import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/session/auth_gate.dart';
import '../../domain/entities/room.dart';
import 'room_detail_cubit.dart';

@RoutePage()
class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({
    super.key,
    required this.roomId,
    required this.hotelId,
    this.checkin,
    this.checkout,
  });

  final int roomId;
  final int hotelId;
  final DateTime? checkin;
  final DateTime? checkout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RoomDetailCubit>()
        ..load(roomId: roomId, hotelId: hotelId, checkin: checkin, checkout: checkout),
      child: _RoomDetailView(hotelId: hotelId),
    );
  }
}

class _RoomDetailView extends StatelessWidget {
  const _RoomDetailView({required this.hotelId});

  final int hotelId;

  Future<void> _book(BuildContext context, RoomDetailState state, Room room) async {
    if (!state.hasDates) {
      final range = await showStayDatesPicker(context);
      if (range != null && context.mounted) {
        await context.read<RoomDetailCubit>().changeDates(range);
      }
      return;
    }
    final customer = await context.ensureCustomer();
    if (customer == null || !context.mounted) return;
    await context.router.push(
      BookingCreateRoute(
        hotelId: hotelId,
        checkin: state.checkin!,
        checkout: state.checkout!,
        preselectedRoomIds: [room.id],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomDetailCubit, RoomDetailState>(
      builder: (context, state) {
        final detail = state.detail.data;
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(ExploreStrings.roomDetailTitle)),
            body: state.detail.isFailure
                ? AppFailureView.fromState(
                    state.detail,
                    onRetry: context.read<RoomDetailCubit>().retry,
                  )
                : const AppLoadingView(),
          );
        }
        final room = detail.room;
        final nights =
            state.hasDates ? DateOnly.nights(state.checkin!, state.checkout!) : 0;
        final bookable = state.statusForDates == RoomStatus.available;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
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
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageCarousel(
                    paths: detail.gallery,
                    placeholderIcon: Icons.bed_rounded,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList.list(
                  children: [
                    Text(ExploreStrings.roomTitle(room.roomNumber), style: AppTextStyles.headline),
                    const Gap(6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (room.roomTypeName.isNotEmpty)
                          SoftTag(label: room.roomTypeName, tone: StatusTone.brand),
                        SoftTag(
                          label: ExploreStrings.capacity(room.capacity),
                          icon: Icons.people_alt_outlined,
                        ),
                        if (room.hotelName != null) SoftTag(label: room.hotelName!),
                      ],
                    ),
                    const Gap(AppSpacing.md),
                    PriceText(
                      room.price,
                      unit: AppStrings.perNight,
                      style: AppTextStyles.moneyLarge,
                      color: AppColors.primaryDark,
                    ),
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: ExploreStrings.availability),
                    const Gap(AppSpacing.xs),
                    StayDatesCard(
                      checkin: state.checkin,
                      checkout: state.checkout,
                      onChanged: context.read<RoomDetailCubit>().changeDates,
                    ),
                    if (state.hasDates) ...[
                      const Gap(AppSpacing.xs),
                      if (state.checkingDates)
                        const LinearProgressIndicator(minHeight: 2)
                      else if (state.statusForDates != null)
                        Row(
                          children: [
                            StatusBadge.room(state.statusForDates!),
                            const Gap(AppSpacing.xs),
                            Expanded(
                              child: Text(
                                bookable
                                    ? ExploreStrings.roomAvailable
                                    : ExploreStrings.roomNotAvailable,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),
                    ],
                    if (detail.amenities.isNotEmpty) ...[
                      const Gap(AppSpacing.xl),
                      const SectionHeader(title: ExploreStrings.roomAmenities),
                      const Gap(AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final amenity in detail.amenities)
                            SoftTag(
                              label: amenity.name,
                              icon: Icons.check_rounded,
                              tone: StatusTone.brand,
                            ),
                        ],
                      ),
                    ],
                    if (room.description.isNotEmpty) ...[
                      const Gap(AppSpacing.xl),
                      const SectionHeader(title: ExploreStrings.about),
                      const Gap(AppSpacing.xs),
                      ExpandableText(room.description),
                    ],
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: state.hasDates
              ? TotalActionBar(
                  label: ExploreStrings.totalForNights(nights),
                  amount: room.price * nights,
                  actionLabel: ExploreStrings.bookThisRoom,
                  onAction: bookable ? () => _book(context, state, room) : null,
                )
              : BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: PriceText(room.price, unit: AppStrings.perNight),
                      ),
                      AppButton(
                        label: ExploreStrings.pickDates,
                        icon: Icons.calendar_month_outlined,
                        onPressed: () => _book(context, state, room),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
