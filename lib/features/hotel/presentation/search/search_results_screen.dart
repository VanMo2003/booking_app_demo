import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/hotel_usecases.dart';
import '../widgets/hotel_card.dart';

@injectable
class SearchResultsCubit extends LoadCubit<List<Hotel>> {
  SearchResultsCubit(this._search);

  final SearchAvailableHotels _search;
  late DateTime checkin;
  late DateTime checkout;

  Future<void> searchFor(DateTime from, DateTime to) {
    checkin = from;
    checkout = to;
    return load();
  }

  @override
  Future<void> load() => guard(() => _search(checkin: checkin, checkout: checkout));
}

/// Kết quả tìm theo ngày: cơ sở còn phòng lên trước.
@RoutePage()
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.checkin,
    required this.checkout,
  });

  final DateTime checkin;
  final DateTime checkout;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final SearchResultsCubit _cubit =
      getIt<SearchResultsCubit>()..searchFor(widget.checkin, widget.checkout);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _changeDates() async {
    final range = await showStayDatesPicker(
      context,
      checkin: _cubit.checkin,
      checkout: _cubit.checkout,
    );
    if (range != null) await _cubit.searchFor(range.start, range.end);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nights = DateOnly.nights(_cubit.checkin, _cubit.checkout);
    return BlocProvider.value(
      value: _cubit,
      child: AppPage(
        title: ExploreStrings.searchTitle,
        subtitle:
            '${Fmt.weekdayDate(_cubit.checkin)} → ${Fmt.weekdayDate(_cubit.checkout)} · ${AppStrings.nights(nights)}',
        actions: [
          IconButton(
            tooltip: ExploreStrings.pickDates,
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: _changeDates,
          ),
        ],
        body: BlocBuilder<SearchResultsCubit, LoadState<List<Hotel>>>(
          builder: (context, state) {
            return LoadStateView<List<Hotel>>(
              state: state,
              onRetry: _cubit.load,
              isEmpty: (hotels) => hotels.isEmpty,
              empty: const AppEmptyView(
                icon: Icons.search_off_rounded,
                title: ExploreStrings.searchEmpty,
              ),
              builder: (context, hotels) {
                final available = hotels.where((h) => h.acceptsBooking).length;
                return RefreshIndicator(
                  onRefresh: _cubit.load,
                  child: ListView.separated(
                    padding: AppSpacing.page,
                    itemCount: hotels.length + 1,
                    separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Text(
                          ExploreStrings.searchSummary(available, hotels.length),
                          style: AppTextStyles.bodySmall,
                        );
                      }
                      final hotel = hotels[index - 1];
                      return HotelCard(
                        hotel: hotel,
                        showAvailability: true,
                        onTap: () => context.router.push(
                          HotelDetailRoute(
                            hotelId: hotel.id,
                            checkin: _cubit.checkin,
                            checkout: _cubit.checkout,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
