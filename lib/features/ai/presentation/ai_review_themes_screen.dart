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

/// Khoảng thời gian xem đánh giá.
enum ReviewWindow {
  month(30),
  quarter(90),
  halfYear(180);

  const ReviewWindow(this.days);

  final int days;
}

@injectable
class AiReviewThemesCubit extends LoadCubit<ReviewThemes> {
  AiReviewThemesCubit(this._themes);

  final GetReviewThemes _themes;
  late int _chainId;
  ReviewWindow _window = ReviewWindow.quarter;

  ReviewWindow get window => _window;

  Future<void> start(int chainId) {
    _chainId = chainId;
    return load();
  }

  Future<void> changeWindow(ReviewWindow window) {
    if (window == _window) return Future.value();
    _window = window;
    return load();
  }

  @override
  Future<void> load() {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: _window.days - 1));
    return guard(() => _themes(_chainId, from: from, to: to));
  }
}

/// AI đọc đánh giá của cả chuỗi và cho biết khách đang nói nhiều về điều gì, cơ sở nào bị nhắc tới.
/// Số đánh giá và điểm trung bình từng cơ sở do máy chủ tính, không phải AI nói.
@RoutePage()
class AiReviewThemesScreen extends StatelessWidget {
  const AiReviewThemesScreen({super.key, required this.hotelChainId, this.subtitle});

  final int hotelChainId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiReviewThemesCubit>()..start(hotelChainId),
      child: _ThemesView(subtitle: subtitle),
    );
  }
}

class _ThemesView extends StatelessWidget {
  const _ThemesView({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AiReviewThemesCubit>();
    return AppPage(
      title: AiStrings.themesTitle,
      subtitle: subtitle,
      actions: [
        IconButton(
          tooltip: AiStrings.pricingRefresh,
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: Column(
        children: [
          const Gap(AppSpacing.sm),
          ChoiceChipBar<ReviewWindow>(
            options: ReviewWindow.values,
            selected: cubit.window,
            labelOf: (window) => AiStrings.themesWindow(window.days),
            onSelected: cubit.changeWindow,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: BlocBuilder<AiReviewThemesCubit, LoadState<ReviewThemes>>(
              builder: (context, state) => LoadStateView<ReviewThemes>(
                state: state,
                onRetry: cubit.load,
                builder: (context, themes) => ListView(
                  padding: AppSpacing.page,
                  children: [
                    Text(
                      AiStrings.themesFrom(Fmt.date(themes.from), Fmt.date(themes.to), themes.reviewCount),
                      style: AppTextStyles.caption,
                    ),
                    for (final note in themes.notes) ...[
                      const Gap(AppSpacing.xs),
                      NoticeBanner(text: note, tone: StatusTone.warning),
                    ],
                    if (themes.summary != null) ...[
                      const Gap(AppSpacing.sm),
                      AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                            const Gap(AppSpacing.xs),
                            Expanded(child: Text(themes.summary!, style: AppTextStyles.bodyMedium)),
                          ],
                        ),
                      ),
                    ],
                    if (themes.themes.isNotEmpty) ...[
                      const Gap(AppSpacing.lg),
                      const SectionHeader(title: AiStrings.themesTopics),
                      const Gap(AppSpacing.xs),
                      for (final theme in themes.themes) ...[
                        _ThemeCard(theme: theme),
                        const Gap(AppSpacing.sm),
                      ],
                    ],
                    if (themes.actions.isNotEmpty) ...[
                      const Gap(AppSpacing.sm),
                      const SectionHeader(title: AiStrings.themesActions),
                      const Gap(AppSpacing.xs),
                      for (final action in themes.actions)
                        IconText(
                          icon: Icons.lightbulb_outline_rounded,
                          iconColor: AppColors.accent,
                          text: action,
                          maxLines: 3,
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                    if (themes.byBranch.isNotEmpty) ...[
                      const Gap(AppSpacing.lg),
                      const SectionHeader(title: AiStrings.themesByBranch),
                      const Gap(AppSpacing.xs),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            for (final branch in themes.byBranch)
                              InfoRow(
                                icon: Icons.apartment_rounded,
                                label: branch.hotelName,
                                value: branch.averageRating == null
                                    ? AiStrings.themesNoReview
                                    : AiStrings.themesBranchValue(
                                        branch.reviews,
                                        Fmt.decimal(branch.averageRating),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.md),
                    Text(AiStrings.themesNote, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.theme});

  final ReviewTheme theme;

  (String, StatusTone, IconData) get _mood => switch (theme.sentiment) {
        ThemeSentiment.good => (AiStrings.themesGood, StatusTone.success, Icons.thumb_up_outlined),
        ThemeSentiment.bad => (AiStrings.themesBad, StatusTone.danger, Icons.thumb_down_outlined),
        ThemeSentiment.mixed => (AiStrings.themesMixed, StatusTone.warning, Icons.swap_vert_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (label, tone, icon) = _mood;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(theme.topic, style: AppTextStyles.bodyStrong, maxLines: 1)),
              const Gap(AppSpacing.xs),
              StatusBadge(label: label, tone: tone, dense: true, icon: icon),
            ],
          ),
          const Gap(4),
          Text(theme.note, style: AppTextStyles.bodySmall),
          if (theme.branches.isNotEmpty) ...[
            const Gap(AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final branch in theme.branches) SoftTag(label: branch, tone: StatusTone.neutral),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
