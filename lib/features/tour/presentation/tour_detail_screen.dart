import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/tour_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../chat/presentation/chat_entry.dart';
import '../domain/entities/tour.dart';
import 'widgets/tour_card.dart';

/// Chi tiết một tour cho khách tham khảo. App chưa đặt tour trực tiếp: nút cuối trang
/// mở tin nhắn tới cơ sở với câu hỏi soạn sẵn để nhân viên xác nhận.
@RoutePage()
class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({super.key, required this.tour, this.hotelName});

  final Tour tour;
  final String? hotelName;

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
        child: AppButton(
          label: TourStrings.ask,
          icon: Icons.chat_bubble_outline_rounded,
          expand: true,
          onPressed: () => context.openHotelChat(tour.hotelId, draft: TourStrings.askDraft(tour.name)),
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
