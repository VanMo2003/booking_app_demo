import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiPromotionCubit extends LoadCubit<PromotionAdvice> {
  AiPromotionCubit(this._advice);

  final GetPromotionAdvice _advice;
  late int _hotelChainId;

  Future<void> start(int hotelChainId) {
    _hotelChainId = hotelChainId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _advice(_hotelChainId));
}

/// AI gợi ý chương trình giảm giá: chỗ nào trong chuỗi đang trống thì nên giảm bao nhiêu, trong bao lâu,
/// vì sao. Màn này không tạo mã nào — chủ chuỗi đọc rồi tự tạo voucher trong mục Mã giảm giá.
@RoutePage()
class AiPromotionScreen extends StatelessWidget {
  const AiPromotionScreen({super.key, required this.hotelChainId, this.subtitle});

  final int hotelChainId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiPromotionCubit>()..start(hotelChainId),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.promoTitle,
          subtitle: subtitle,
          actions: [
            IconButton(
              tooltip: AiStrings.pricingRefresh,
              onPressed: context.read<AiPromotionCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: BlocBuilder<AiPromotionCubit, LoadState<PromotionAdvice>>(
            builder: (context, state) => LoadStateView<PromotionAdvice>(
              state: state,
              onRetry: context.read<AiPromotionCubit>().load,
              builder: (context, advice) => ListView(
                padding: AppSpacing.page,
                children: [
                  _FiguresCard(advice: advice),
                  for (final note in advice.notes) ...[
                    const Gap(AppSpacing.xs),
                    NoticeBanner(text: note, tone: StatusTone.warning),
                  ],
                  if (advice.campaigns.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: AiStrings.promoCampaigns),
                    const Gap(AppSpacing.xs),
                    for (final campaign in advice.campaigns) ...[
                      _CampaignCard(campaign: campaign, hotelChainId: hotelChainId, subtitle: subtitle),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                  if (advice.runningVouchers.isNotEmpty) ...[
                    const Gap(AppSpacing.md),
                    const SectionHeader(title: AiStrings.promoRunning),
                    const Gap(AppSpacing.xs),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          for (final voucher in advice.runningVouchers)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: IconText(
                                icon: Icons.local_offer_outlined,
                                iconColor: AppColors.primary,
                                text: voucher,
                                maxLines: 2,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const Gap(AppSpacing.md),
                  Text(AiStrings.promoNote, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FiguresCard extends StatelessWidget {
  const _FiguresCard({required this.advice});

  final PromotionAdvice advice;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (advice.from != null && advice.to != null)
            Text(
              AiStrings.promoPeriod(Fmt.date(advice.from), Fmt.date(advice.to)),
              style: AppTextStyles.bodySmall,
            ),
          const Gap(AppSpacing.xs),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (advice.occupancyRate != null)
                SoftTag(label: AiStrings.promoOccupancy(Fmt.decimal(advice.occupancyRate))),
              if (advice.outlookOccupancy != null)
                SoftTag(label: AiStrings.promoOutlook(Fmt.decimal(advice.outlookOccupancy))),
              if (advice.adr != null) SoftTag(label: AiStrings.promoAdr(Fmt.money(advice.adr))),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.hotelChainId, this.subtitle});

  final PromotionCampaign campaign;
  final int hotelChainId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(campaign.title, style: AppTextStyles.bodyStrong, maxLines: 2)),
              const Gap(AppSpacing.xs),
              StatusBadge(label: '-${campaign.discountPercent}%', tone: StatusTone.success, dense: true),
            ],
          ),
          const Gap(4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SoftTag(label: campaign.chainWide ? AiStrings.promoChainWide : campaign.hotelName ?? ''),
              if (campaign.startsAt != null && campaign.endsAt != null)
                SoftTag(label: AiStrings.promoRun(Fmt.date(campaign.startsAt), Fmt.date(campaign.endsAt))),
              if (campaign.minOrderAmount != null)
                SoftTag(label: '${AiStrings.promoMinOrder} ${Fmt.money(campaign.minOrderAmount)}'),
            ],
          ),
          const Gap(4),
          Text(campaign.why, style: AppTextStyles.bodySmall),
          if (campaign.tours.isNotEmpty) ...[
            const Gap(4),
            IconText(
              icon: Icons.tour_outlined,
              iconColor: AppColors.primary,
              text: '${AiStrings.promoTours}: ${campaign.tours.join(', ')}',
              maxLines: 2,
              style: AppTextStyles.bodySmall,
            ),
          ],
          const Gap(4),
          Align(
            alignment: Alignment.centerLeft,
            // Màn này không tạo mã: nút chỉ mở đúng trang mã giảm giá để chủ chuỗi tự tạo.
            child: AppButton.text(
              label: AiStrings.promoCreate,
              size: AppButtonSize.small,
              icon: Icons.local_offer_outlined,
              onPressed: () => context.router.push(
                VouchersRoute(hotelChainId: hotelChainId, subtitle: subtitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
