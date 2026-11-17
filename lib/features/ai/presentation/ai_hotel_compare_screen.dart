import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiHotelCompareCubit extends LoadCubit<HotelCompare> {
  AiHotelCompareCubit(this._compare);

  final CompareHotelsWithAi _compare;
  late List<int> _hotelIds;

  Future<void> start(List<int> hotelIds) {
    _hotelIds = hotelIds;
    return load();
  }

  @override
  Future<void> load() => guard(() => _compare(_hotelIds));
}

/// Vài cơ sở khách đang cân nhắc, đặt cạnh nhau. Mọi con số trong bảng do máy chủ đếm từ dữ liệu
/// thật của từng cơ sở; AI chỉ viết mỗi cơ sở hợp với ai, khác nhau ở đâu và nên chọn gì.
@RoutePage()
class AiHotelCompareScreen extends StatelessWidget {
  const AiHotelCompareScreen({super.key, required this.hotelIds});

  final List<int> hotelIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiHotelCompareCubit>()..start(hotelIds),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.compareTitle,
          body: BlocBuilder<AiHotelCompareCubit, LoadState<HotelCompare>>(
            builder: (context, state) => LoadStateView<HotelCompare>(
              state: state,
              onRetry: context.read<AiHotelCompareCubit>().load,
              builder: (context, compare) => ListView(
                padding: AppSpacing.page,
                children: [
                  for (final note in compare.notes) ...[
                    NoticeBanner(text: note, tone: StatusTone.warning),
                    const Gap(AppSpacing.xs),
                  ],
                  if (compare.verdict != null) ...[
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                              const Gap(AppSpacing.xs),
                              Expanded(
                                child: Text(AiStrings.compareVerdict, style: AppTextStyles.bodyStrong),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.xs),
                          Text(compare.verdict!, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.md),
                  ],
                  if (compare.differences.isNotEmpty) ...[
                    const SectionHeader(title: AiStrings.compareDifferences),
                    const Gap(AppSpacing.xs),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          for (final line in compare.differences)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: IconText(
                                icon: Icons.compare_arrows_rounded,
                                iconColor: AppColors.primary,
                                text: line,
                                maxLines: 3,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.md),
                  ],
                  const SectionHeader(title: AiStrings.compareTable),
                  const Gap(AppSpacing.xs),
                  for (final item in compare.items) ...[
                    _CompareCard(item: item),
                    const Gap(AppSpacing.sm),
                  ],
                  const Gap(AppSpacing.xs),
                  Text(AiStrings.compareNote, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.item});

  final CompareItem item;

  String get _price {
    if (item.priceFrom == null) return AiStrings.compareNoPrice;
    if (item.priceTo == null || item.priceTo == item.priceFrom) return Fmt.money(item.priceFrom);
    return '${Fmt.money(item.priceFrom)} – ${Fmt.money(item.priceTo)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.bodyStrong, maxLines: 2),
          if (item.address != null) Text(item.address!, style: AppTextStyles.caption, maxLines: 2),
          const Gap(AppSpacing.xs),
          InfoRow(label: AiStrings.compareRowPrice, value: _price),
          InfoRow(
            label: AiStrings.compareRowRooms,
            value: AiStrings.compareRooms(item.rooms, item.maxCapacity),
          ),
          InfoRow(
            label: AiStrings.compareRowExtras,
            value: AiStrings.compareExtras(item.amenities, item.services, item.tours),
          ),
          InfoRow(
            label: AiStrings.compareRowReviews,
            value: item.reviews == 0
                ? AiStrings.compareNoReview
                : AiStrings.compareReviews(item.reviews, Fmt.decimal(item.averageRating)),
          ),
          if (item.fitFor != null) ...[
            const Gap(AppSpacing.xs),
            IconText(
              icon: Icons.auto_awesome_rounded,
              iconColor: AppColors.accent,
              text: item.fitFor!,
              maxLines: 3,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
