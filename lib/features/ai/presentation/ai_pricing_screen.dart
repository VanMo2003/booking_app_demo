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
class AiPricingCubit extends LoadCubit<PricingAdvice> {
  AiPricingCubit(this._advice);

  final GetPricingAdvice _advice;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _advice(_hotelId));
}

/// AI tư vấn giá phòng: với từng loại phòng, nên tăng, giữ hay giảm và vì sao — kèm đúng những con số
/// của cơ sở mà kết luận dựa vào. Không tự đổi giá phòng nào; quản lý tự quyết rồi sửa trong mục Phòng.
@RoutePage()
class AiPricingScreen extends StatelessWidget {
  const AiPricingScreen({super.key, required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiPricingCubit>()..start(hotelId),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.pricingTitle,
          subtitle: subtitle,
          actions: [
            IconButton(
              tooltip: AiStrings.pricingRefresh,
              onPressed: context.read<AiPricingCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: BlocBuilder<AiPricingCubit, LoadState<PricingAdvice>>(
            builder: (context, state) => LoadStateView<PricingAdvice>(
              state: state,
              onRetry: context.read<AiPricingCubit>().load,
              builder: (context, advice) => ListView(
                padding: AppSpacing.page,
                children: [
                  Text(
                    AiStrings.pricingPeriod(Fmt.date(advice.from), Fmt.date(advice.to), advice.outlookDays),
                    style: AppTextStyles.caption,
                  ),
                  for (final note in advice.notes) ...[
                    const Gap(AppSpacing.xs),
                    NoticeBanner(text: note, tone: StatusTone.warning),
                  ],
                  if (advice.summary != null) ...[
                    const Gap(AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                          const Gap(AppSpacing.xs),
                          Expanded(child: Text(advice.summary!, style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    ),
                  ],
                  if (advice.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.lg),
                      child: AppEmptyView(
                        icon: Icons.price_change_outlined,
                        title: AiStrings.pricingEmpty,
                        compact: true,
                      ),
                    )
                  else ...[
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: AiStrings.pricingByType),
                    const Gap(AppSpacing.xs),
                    for (final item in advice.items) ...[
                      _ItemCard(item: item),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                  if (advice.risks.isNotEmpty) ...[
                    const Gap(AppSpacing.md),
                    const SectionHeader(title: AiStrings.pricingRisks),
                    const Gap(AppSpacing.xs),
                    for (final risk in advice.risks)
                      IconText(
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.warning,
                        text: risk,
                        maxLines: 3,
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                  const Gap(AppSpacing.md),
                  Text(AiStrings.pricingNote, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final PricingItem item;

  (String, StatusTone, IconData) get _action => switch (item.action) {
        PricingAction.raise => (AiStrings.pricingRaise, StatusTone.success, Icons.trending_up_rounded),
        PricingAction.lower => (AiStrings.pricingLower, StatusTone.warning, Icons.trending_down_rounded),
        PricingAction.hold => (AiStrings.pricingHold, StatusTone.neutral, Icons.trending_flat_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (label, tone, icon) = _action;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.roomTypeName, style: AppTextStyles.bodyStrong, maxLines: 1),
              ),
              const Gap(AppSpacing.xs),
              StatusBadge(
                label: item.percent == null ? label : '$label ${item.percent}%',
                tone: tone,
                dense: true,
                icon: icon,
              ),
            ],
          ),
          if (item.suggestedPrice != null) ...[
            const Gap(4),
            Row(
              children: [
                Text(
                  Fmt.money(item.listPrice),
                  style: AppTextStyles.bodySmall.copyWith(decoration: TextDecoration.lineThrough),
                ),
                const Gap(AppSpacing.xs),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.inkTertiary),
                const Gap(AppSpacing.xs),
                Text(
                  Fmt.money(item.suggestedPrice),
                  style: AppTextStyles.bodyStrong.colored(AppColors.primary),
                ),
              ],
            ),
          ],
          if (item.reason != null) ...[
            const Gap(4),
            Text(item.reason!, style: AppTextStyles.bodySmall),
          ],
          const Gap(AppSpacing.xs),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SoftTag(label: AiStrings.pricingRooms(item.rooms), tone: StatusTone.neutral),
              SoftTag(label: AiStrings.pricingOccupancy(Fmt.decimal(item.occupancyRate)), tone: StatusTone.brand),
              if (item.listPrice > 0)
                SoftTag(label: AiStrings.pricingList(Fmt.money(item.listPrice)), tone: StatusTone.neutral),
              if (item.adr > 0) SoftTag(label: AiStrings.pricingAdr(Fmt.money(item.adr)), tone: StatusTone.neutral),
            ],
          ),
        ],
      ),
    );
  }
}
