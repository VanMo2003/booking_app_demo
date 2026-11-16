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
import '../../tour/presentation/tour_detail_screen.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiTourSearchCubit extends LoadCubit<AiTourSearchResult> {
  AiTourSearchCubit(this._search);

  final SearchToursWithAi _search;
  String _query = '';

  Future<void> search(String query) {
    _query = query.trim();
    if (_query.isEmpty) return Future.value();
    return load();
  }

  @override
  Future<void> load() => guard(() => _search(_query));
}

/// Tìm tour bằng một câu mô tả chuyến đi. AI chỉ đọc yêu cầu thành bộ lọc (điểm đến, chủ đề, ngày, số
/// khách, mức giá); tour, giá khuyến mãi và chỗ còn lại do máy chủ lọc trên dữ liệu thật.
@RoutePage()
class AiTourSearchScreen extends StatelessWidget {
  const AiTourSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AiTourSearchCubit>();
        if (initialQuery != null) cubit.search(initialQuery!);
        return cubit;
      },
      child: _AiTourSearchView(initialQuery: initialQuery),
    );
  }
}

class _AiTourSearchView extends StatefulWidget {
  const _AiTourSearchView({this.initialQuery});

  final String? initialQuery;

  @override
  State<_AiTourSearchView> createState() => _AiTourSearchViewState();
}

class _AiTourSearchViewState extends State<_AiTourSearchView> {
  late final _query = TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? text]) {
    if (text != null) _query.text = text;
    FocusScope.of(context).unfocus();
    context.read<AiTourSearchCubit>().search(_query.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AiStrings.tourTitle,
      body: BlocBuilder<AiTourSearchCubit, LoadState<AiTourSearchResult>>(
        builder: (context, state) {
          final busy = state.isLoading;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(AiStrings.tourIntro, style: AppTextStyles.bodySmall),
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
                          hintText: AiStrings.tourHint,
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
                ViewStatus.initial => [_TourExamples(onPick: _submit)],
                ViewStatus.loading when !state.hasData => const [AppLoadingView()],
                ViewStatus.failure => [
                    AppFailureView.fromState(state, onRetry: () => _submit(), compact: true),
                    const Gap(AppSpacing.md),
                    _TourExamples(onPick: _submit),
                  ],
                _ => [_TourResults(result: state.data!)],
              },
            ],
          );
        },
      ),
    );
  }
}

class _TourExamples extends StatelessWidget {
  const _TourExamples({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.examplesTitle),
        for (final example in AiStrings.tourExamples) ...[
          AppCard(
            onTap: () => onPick(example),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: IconText(
              icon: Icons.north_west_rounded,
              iconColor: AppColors.primary,
              text: example,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

/// Điều AI hiểu, viết thành các thẻ nhỏ để khách kiểm lại bằng mắt.
abstract final class AiTourSearchChips {
  static List<String> of(AiTourFilters f) => [
        ...f.destinations.take(2),
        for (final theme in f.themes) theme.label,
        if (f.tourDate != null) Fmt.date(f.tourDate),
        if (f.adults != null) AiStrings.tourGuests(f.adults!, f.children ?? 0),
        if (f.minPrice != null && f.maxPrice != null)
          AiStrings.priceBetween(Fmt.money(f.minPrice), Fmt.money(f.maxPrice))
        else if (f.maxPrice != null)
          AiStrings.priceUnder(Fmt.money(f.maxPrice))
        else if (f.minPrice != null)
          AiStrings.priceOver(Fmt.money(f.minPrice)),
        if (f.nights != null) AiStrings.tourNights(f.nights!),
        if (f.withRooms == true) AiStrings.tourWithRooms,
        if (f.withRooms == false) AiStrings.tourWithoutRooms,
        ...f.keywords.take(3),
      ];
}

class _TourResults extends StatelessWidget {
  const _TourResults({required this.result});

  final AiTourSearchResult result;

  @override
  Widget build(BuildContext context) {
    final tags = AiTourSearchChips.of(result.filters);
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
            icon: Icons.tour_outlined,
            title: AiStrings.tourNoResults,
            message: AiStrings.tourNoResultsHint,
            compact: true,
          )
        else ...[
          SectionHeader(title: AiStrings.tourResultsCount(result.results.length)),
          const Gap(AppSpacing.sm),
          for (final tour in result.results) ...[
            TourCardLink(tour: tour, hotelName: tour.hotelName),
            const Gap(AppSpacing.xs),
          ],
        ],
      ],
    );
  }
}
