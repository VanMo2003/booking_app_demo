import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/discover_strings.dart';
import '../../../core/text/tour_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/auth_gate.dart';
import '../../chat/presentation/chat_entry.dart';
import '../domain/entities/tour.dart';
import '../domain/usecases/tour_usecases.dart';
import 'share_tour.dart';
import 'widgets/tour_card.dart';
import 'widgets/tour_discover_widgets.dart';

/// Chi tiết một tour cho khách: điểm đến, giá người lớn / trẻ em (kèm khuyến mãi), lịch trình dạng timeline,
/// những gì bao gồm, phòng của gói, điều khoản huỷ, khách sạn tổ chức. Mở được từ [tour] có sẵn hoặc chỉ
/// [tourId] (link chia sẻ, thông báo khuyến mãi). Cuối trang: "Đặt tour" hoặc hỏi khách sạn qua tin nhắn.
@RoutePage()
class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, this.tour, this.tourId, this.hotelName});

  final Tour? tour;
  final int? tourId;
  final String? hotelName;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late LoadState<Tour> _state =
      widget.tour == null ? const LoadState<Tour>() : const LoadState<Tour>().toSuccess(widget.tour as Tour);

  @override
  void initState() {
    super.initState();
    if (widget.tour == null) _load();
  }

  Future<void> _load() async {
    final id = widget.tourId;
    if (id == null) return;
    setState(() => _state = _state.toLoading());
    try {
      final tour = await getIt<GetTour>()(id);
      if (mounted) setState(() => _state = _state.toSuccess(tour));
    } catch (error) {
      if (mounted) setState(() => _state = _state.toError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = _state.data;
    if (tour == null) {
      return AppPage(
        title: TourStrings.title,
        body: _state.isFailure ? AppFailureView.fromState(_state, onRetry: _load) : const AppLoadingView(),
      );
    }
    return _TourDetailBody(tour: tour, hotelName: widget.hotelName ?? tour.hotelName);
  }
}

class _TourDetailBody extends StatelessWidget {
  const _TourDetailBody({required this.tour, this.hotelName});

  final Tour tour;
  final String? hotelName;

  Future<void> _book(BuildContext context) async {
    final customer = await context.ensureCustomer();
    if (customer == null || !context.mounted) return;
    await context.router.push(TourBookingFormRoute(tour: tour, hotelName: hotelName));
  }

  List<String> get _includes => (tour.includes ?? '')
      .split(RegExp(r'[,;\n]'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final paused = !tour.available;
    final meta = tourMeta(tour);
    return AppPage(
      title: tour.name,
      subtitle: hotelName,
      actions: [
        IconButton(
          tooltip: DiscoverStrings.share,
          icon: const Icon(Icons.share_rounded),
          onPressed: () => shareTour(context, tour),
        ),
      ],
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppNetworkImage(path: tour.pathImage, placeholderIcon: Icons.tour_outlined),
                ),
              ),
              if (tour.onSale && tour.discountPercent != null)
                Positioned(left: 10, top: 10, child: SaleBadge(percent: tour.discountPercent!)),
            ],
          ),
          const Gap(AppSpacing.md),
          if (tour.destination != null) ...[
            IconText(icon: Icons.place_rounded, text: tour.destination!, style: AppTextStyles.bodySmall),
            const Gap(4),
          ],
          Text(tour.name, style: AppTextStyles.title),
          if (meta.isNotEmpty) ...[
            const Gap(4),
            IconText(icon: Icons.schedule_rounded, text: meta, style: AppTextStyles.caption),
          ],
          const Gap(AppSpacing.sm),
          Row(
            children: [
              Expanded(child: TourPriceTag(tour: tour, large: true)),
              if (paused) const StatusBadge(label: TourStrings.paused, tone: StatusTone.neutral),
            ],
          ),
          if (tour.themes.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            ThemeTags(themes: tour.themes),
          ],
          const Gap(AppSpacing.lg),
          const SectionHeader(title: DiscoverStrings.pricesTitle),
          const Gap(AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.person_rounded,
                  label: DiscoverStrings.adultPrice,
                  value: Fmt.money(tour.salePrice),
                ),
                InfoRow(
                  icon: Icons.child_care_rounded,
                  label: DiscoverStrings.childPrice,
                  value: tour.childPrice == null ? DiscoverStrings.childSameAsAdult : Fmt.money(tour.childPayPrice),
                ),
                if (tour.maxGuests != null)
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: TourStrings.maxGuests,
                    value: TourStrings.maxGuestsValue(tour.maxGuests!),
                  ),
                if (tour.onSale)
                  InfoRow(
                    icon: Icons.local_offer_rounded,
                    label: DiscoverStrings.saleOpen,
                    value: tour.promotionEndsAt == null
                        ? DiscoverStrings.salePercent(tour.discountPercent ?? 0)
                        : DiscoverStrings.saleUntil(Fmt.date(tour.promotionEndsAt)),
                  ),
              ],
            ),
          ),
          if (tour.itinerary.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: DiscoverStrings.itinerary),
            const Gap(AppSpacing.sm),
            ItineraryTimeline(steps: tour.itinerary),
          ],
          if (_includes.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: DiscoverStrings.includes),
            const Gap(AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in _includes)
                  Chip(
                    avatar: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                    label: Text(item),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const Gap(AppSpacing.lg),
          const SectionHeader(title: TourStrings.roomsSection),
          const Gap(AppSpacing.xs),
          if (tour.withRooms) ...[
            Text(TourStrings.stayInfo(tour.stayNights), style: AppTextStyles.bodySmall),
            const Gap(AppSpacing.xs),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < tour.rooms.length; i++) ...[
                    if (i > 0) const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          AppNetworkImage(
                            path: tour.rooms[i].pathImage,
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
                                Text(
                                  'Phòng ${tour.rooms[i].roomNumber} · ${tour.rooms[i].roomTypeName}',
                                  style: AppTextStyles.bodyStrong,
                                ),
                                Text(TourStrings.capacity(tour.rooms[i].capacity), style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          PriceText(tour.rooms[i].price, unit: TourStrings.perNight),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else
            Text(TourStrings.withoutRooms, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.lg),
          const SectionHeader(title: DiscoverStrings.cancellation),
          const Gap(AppSpacing.xs),
          NoticeBanner(
            text: tour.cancellationPolicy ?? DiscoverStrings.cancellationDefault,
            icon: Icons.event_busy_rounded,
          ),
          if (tour.description.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: TourStrings.description),
            const Gap(AppSpacing.xs),
            ExpandableText(tour.description),
          ],
          const Gap(AppSpacing.lg),
          const SectionHeader(title: DiscoverStrings.organizedBy),
          const Gap(AppSpacing.xs),
          AppCard(
            onTap: () => context.router.push(HotelDetailRoute(hotelId: tour.hotelId)),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.apartment_rounded, color: AppColors.primary),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotelName ?? DiscoverStrings.viewHotel, style: AppTextStyles.bodyStrong),
                      if (tour.hotelAddress != null)
                        Text(tour.hotelAddress!, style: AppTextStyles.caption, maxLines: 2),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          const NoticeBanner(text: TourStrings.bookingNote, icon: Icons.support_agent_rounded),
        ],
      ),
      bottomBar: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: AppButton.tonal(
                label: TourStrings.askShort,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => context.openHotelChat(tour.hotelId, draft: TourStrings.askDraft(tour.name)),
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: TourStrings.book,
                icon: Icons.event_available_rounded,
                onPressed: paused ? null : () => _book(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toàn bộ tour của một cơ sở, phía khách.
@RoutePage()
class HotelToursScreen extends StatelessWidget {
  const HotelToursScreen({super.key, required this.tours, this.hotelName});

  final List<Tour> tours;
  final String? hotelName;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: TourStrings.title,
      subtitle: hotelName,
      body: tours.isEmpty
          ? const AppEmptyView(icon: Icons.tour_outlined, title: TourStrings.guestEmpty)
          : ListView.separated(
              padding: AppSpacing.page,
              itemCount: tours.length,
              separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
              itemBuilder: (context, index) => TourCardLink(tour: tours[index], hotelName: hotelName),
            ),
    );
  }
}

/// Thẻ tour mở trang chi tiết khi chạm.
class TourCardLink extends StatelessWidget {
  const TourCardLink({super.key, required this.tour, this.hotelName});

  final Tour tour;
  final String? hotelName;

  @override
  Widget build(BuildContext context) {
    return TourCard(
      tour: tour,
      onTap: () => context.router.push(TourDetailRoute(tour: tour, hotelName: hotelName)),
    );
  }
}
