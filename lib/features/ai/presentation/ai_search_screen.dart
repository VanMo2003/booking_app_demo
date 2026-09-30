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
class AiSearchCubit extends LoadCubit<AiSearchResult> {
  AiSearchCubit(this._search);

  final SearchWithAi _search;
  String _query = '';

  Future<void> search(String query) {
    _query = query.trim();
    if (_query.isEmpty) return Future.value();
    return load();
  }

  @override
  Future<void> load() => guard(() => _search(_query));
}

/// Tìm phòng bằng một câu mô tả. AI chỉ đọc yêu cầu thành bộ lọc; cơ sở, phòng
/// trống và giá do máy chủ lọc trên dữ liệu thật.
@RoutePage()
class AiSearchScreen extends StatelessWidget {
  const AiSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AiSearchCubit>();
        if (initialQuery != null) cubit.search(initialQuery!);
        return cubit;
      },
      child: _AiSearchView(initialQuery: initialQuery),
    );
  }
}

class _AiSearchView extends StatefulWidget {
  const _AiSearchView({this.initialQuery});

  final String? initialQuery;

  @override
  State<_AiSearchView> createState() => _AiSearchViewState();
}

class _AiSearchViewState extends State<_AiSearchView> {
  late final _query = TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? text]) {
    if (text != null) _query.text = text;
    FocusScope.of(context).unfocus();
    context.read<AiSearchCubit>().search(_query.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AiStrings.searchTitle,
      body: BlocBuilder<AiSearchCubit, LoadState<AiSearchResult>>(
        builder: (context, state) {
          final busy = state.isLoading;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(AiStrings.searchIntro, style: AppTextStyles.bodySmall),
              const Gap(AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                    ),
                    const Gap(AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _query,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 300,
                        textInputAction: TextInputAction.search,
                        onSubmitted: busy ? null : (_) => _submit(),
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: AiStrings.searchHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          counterText: '',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: AiStrings.searchAction,
                      onPressed: busy ? null : _submit,
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              ...switch (state.status) {
                ViewStatus.initial => [_Examples(onPick: _submit)],
                ViewStatus.loading when !state.hasData => const [AppLoadingView()],
                ViewStatus.failure => [
                    AppFailureView.fromState(state, onRetry: () => _submit(), compact: true),
                    const Gap(AppSpacing.md),
                    _Examples(onPick: _submit),
                  ],
                _ => [_Results(result: state.data!)],
              },
            ],
          );
        },
      ),
    );
  }
}

class _Examples extends StatelessWidget {
  const _Examples({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GroupLabel(AiStrings.examplesTitle),
        for (final example in AiStrings.examples) ...[
          ActionChip(
            avatar: const Icon(Icons.north_west_rounded, size: 16),
            label: Text(example),
            onPressed: () => onPick(example),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.result});

  final AiSearchResult result;

  static List<String> chips(AiSearchFilters f) => [
        if (f.hasDates) '${Fmt.dayMonth(f.checkin)} – ${Fmt.dayMonth(f.checkout)}',
        if (f.guests != null) AiStrings.guests(f.guests!),
        if (f.minPrice != null && f.maxPrice != null)
          AiStrings.priceBetween(Fmt.money(f.minPrice), Fmt.money(f.maxPrice))
        else if (f.maxPrice != null)
          AiStrings.priceUnder(Fmt.money(f.maxPrice))
        else if (f.minPrice != null)
          AiStrings.priceOver(Fmt.money(f.minPrice)),
        ...f.areas.take(2),
        ...f.amenities,
        if (f.category != null) f.category!,
      ];

  @override
  Widget build(BuildContext context) {
    final filters = result.filters;
    final tags = chips(filters);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.understood),
        if (result.summary != null) ...[
          Text(result.summary!, style: AppTextStyles.bodyMedium),
          const Gap(AppSpacing.xs),
        ],
        if (tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final tag in tags) SoftTag(label: tag, tone: StatusTone.brand)],
          ),
        for (final note in result.notes) ...[
          const Gap(AppSpacing.xs),
          NoticeBanner(text: note, tone: StatusTone.warning),
        ],
        const Gap(AppSpacing.lg),
        if (result.results.isEmpty)
          const AppEmptyView(
            icon: Icons.travel_explore_rounded,
            title: AiStrings.noResults,
            message: AiStrings.noResultsHint,
            compact: true,
          )
        else ...[
          SectionHeader(title: AiStrings.resultsCount(result.results.length)),
          const Gap(AppSpacing.sm),
          for (final match in result.results) ...[
            _MatchCard(match: match, filters: filters),
            const Gap(AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.filters});

  final AiHotelMatch match;
  final AiSearchFilters filters;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.router.push(
        HotelDetailRoute(
          hotelId: match.hotelId,
          checkin: filters.checkin,
          checkout: filters.checkout,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(path: match.image, width: 88, height: 88, borderRadius: AppRadius.smAll),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.name, style: AppTextStyles.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Gap(2),
                IconText(icon: Icons.location_on_outlined, text: match.address, iconSize: 14),
                const Gap(6),
                Text(
                  '${AiStrings.roomsMatching(match.matchingRooms)} · '
                  '${AiStrings.fromPrice(Fmt.money(match.fromPrice))}',
                  style: AppTextStyles.captionStrong.colored(AppColors.primaryDark),
                ),
                if (match.matchedAmenities.isNotEmpty) ...[
                  const Gap(6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final amenity in match.matchedAmenities)
                        SoftTag(label: amenity, icon: Icons.check_rounded, tone: StatusTone.success),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
