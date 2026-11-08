import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/bloc/paged_cubit.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/discover_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour.dart';
import '../../domain/entities/travel_theme.dart';
import '../widgets/tour_card.dart';
import 'discover_cubits.dart';

/// Tìm tour ở mọi khách sạn: gõ điểm đến hoặc tên tour (không cần dấu), lọc theo chủ đề và mức giá.
@RoutePage()
class TourSearchScreen extends StatelessWidget {
  const TourSearchScreen({super.key, this.query, this.theme});

  final String? query;
  final TravelTheme? theme;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TourSearchCubit>()..apply(TourFilter(query: query ?? '', theme: theme)),
      child: _TourSearchView(initialQuery: query ?? ''),
    );
  }
}

class _TourSearchView extends StatefulWidget {
  const _TourSearchView({required this.initialQuery});

  final String initialQuery;

  @override
  State<_TourSearchView> createState() => _TourSearchViewState();
}

class _TourSearchViewState extends State<_TourSearchView> {
  static const _prices = <double?>[null, 500000, 1000000, 2000000];

  late final _query = TextEditingController(text: widget.initialQuery);
  Timer? _debounce;

  TourSearchCubit get _cubit => context.read<TourSearchCubit>();

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQuery(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _cubit.apply(_cubit.filter.copyWith(query: text)));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: DiscoverStrings.searchTitle,
      body: BlocBuilder<TourSearchCubit, PagedState<Tour>>(
        builder: (context, state) {
          final filter = _cubit.filter;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _query,
                  autofocus: widget.initialQuery.isEmpty,
                  textInputAction: TextInputAction.search,
                  onChanged: _onQuery,
                  onSubmitted: (text) => _cubit.apply(filter.copyWith(query: text)),
                  decoration: InputDecoration(
                    hintText: DiscoverStrings.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Xoá',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _query.clear();
                              _cubit.apply(filter.copyWith(query: ''));
                            },
                          ),
                  ),
                ),
              ),
              ChoiceChipBar<TravelTheme?>(
                options: [null, ...TravelTheme.values],
                selected: filter.theme,
                labelOf: (theme) => theme?.label ?? DiscoverStrings.anyTheme,
                onSelected: (theme) => _cubit.apply(filter.copyWith(theme: () => theme)),
              ),
              const Gap(AppSpacing.xs),
              ChoiceChipBar<double?>(
                options: _prices,
                selected: filter.maxPrice,
                labelOf: (price) =>
                    price == null ? DiscoverStrings.anyPrice : DiscoverStrings.underPrice(Fmt.moneyCompact(price)),
                onSelected: (price) => _cubit.apply(filter.copyWith(maxPrice: () => price)),
              ),
              if (state.status == ViewStatus.success)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(DiscoverStrings.resultCount(state.total), style: AppTextStyles.caption),
                ),
              Expanded(
                child: PagedListView<Tour>(
                  state: state,
                  onRefresh: _cubit.load,
                  onLoadMore: _cubit.loadMore,
                  empty: const AppEmptyView(
                    icon: Icons.travel_explore_rounded,
                    title: DiscoverStrings.noResults,
                    message: DiscoverStrings.noResultsHint,
                  ),
                  itemBuilder: (context, tour) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: TourCard(
                      tour: tour,
                      onTap: () => context.router.push(TourDetailRoute(tour: tour, hotelName: tour.hotelName)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
