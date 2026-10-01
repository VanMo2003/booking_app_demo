import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/tour_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/auth_gate.dart';
import '../../chat/presentation/chat_entry.dart';
import '../domain/entities/tour.dart';
import 'widgets/tour_card.dart';

/// Chi tiết một tour cho khách: thông tin tour, các phòng của gói (đặt tour là đặt luôn phòng ở
/// từ ngày đi tour). Cuối trang: "Đặt tour" (chọn ngày, phòng trong ứng dụng) hoặc hỏi khách sạn qua tin nhắn.
@RoutePage()
class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({super.key, required this.tour, this.hotelName});

  final Tour tour;
  final String? hotelName;

  Future<void> _book(BuildContext context) async {
    final customer = await context.ensureCustomer();
    if (customer == null || !context.mounted) return;
    await context.router.push(TourBookingFormRoute(tour: tour, hotelName: hotelName));
  }

  @override
  Widget build(BuildContext context) {
    final paused = !tour.available;
    return AppPage(
      title: tour.name,
      subtitle: hotelName,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: AppNetworkImage(path: tour.pathImage, placeholderIcon: Icons.tour_outlined),
            ),
          ),
          const Gap(AppSpacing.md),
          Text(tour.name, style: AppTextStyles.title),
          const Gap(AppSpacing.xs),
          Row(
            children: [
              PriceText(tour.price, unit: TourStrings.perGuest, style: AppTextStyles.moneyLarge),
              const Spacer(),
              if (paused) const StatusBadge(label: TourStrings.paused, tone: StatusTone.neutral),
            ],
          ),
          const Gap(AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                if (tour.duration != null)
                  InfoRow(icon: Icons.timelapse_rounded, label: TourStrings.duration, value: tour.duration!),
                if (tour.departure != null)
                  InfoRow(icon: Icons.schedule_rounded, label: TourStrings.departure, value: tour.departure!),
                if (tour.maxGuests != null)
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: TourStrings.maxGuests,
                    value: TourStrings.maxGuestsValue(tour.maxGuests!),
                  ),
                InfoRow(
                  icon: Icons.payments_outlined,
                  label: TourStrings.pricePerGuest,
                  value: '${Fmt.money(tour.price)}${TourStrings.perGuest}',
                ),
              ],
            ),
          ),
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
          if (tour.includes != null) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: TourStrings.includes),
            const Gap(AppSpacing.xs),
            Text(tour.includes!, style: AppTextStyles.body),
          ],
          if (tour.description.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: TourStrings.description),
            const Gap(AppSpacing.xs),
            ExpandableText(tour.description),
          ],
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
