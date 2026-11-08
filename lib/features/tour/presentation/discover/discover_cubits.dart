import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/bloc/paged_cubit.dart';
import '../../../../core/network/paged.dart';
import '../../../voucher/data/voucher_repository.dart';
import '../../../voucher/domain/entities/voucher.dart';
import '../../data/interest_store.dart';
import '../../domain/entities/tour.dart';
import '../../domain/entities/travel_theme.dart';
import '../../domain/usecases/tour_usecases.dart';

/// Trang chủ của khách cùng những gì đi kèm: sở thích đang chọn, mã giảm giá đang chạy.
class TourHomeView extends Equatable {
  const TourHomeView({required this.home, required this.interests, this.vouchers = const []});

  final TourHome home;
  final List<TravelTheme> interests;
  final List<Voucher> vouchers;

  @override
  List<Object?> get props => [home, interests, vouchers];
}

@injectable
class TourHomeCubit extends LoadCubit<TourHomeView> {
  TourHomeCubit(this._home, this._interests, this._vouchers);

  final GetTourHome _home;
  final InterestStore _interests;
  final VoucherRepository _vouchers;

  @override
  Future<void> load() => guard(() async {
        final interests = _interests.interests;
        final home = _home(interests);
        // Mã giảm giá chỉ là phần phụ: lỗi thì để trống.
        final vouchers = _vouchers.available().catchError((_) => const <Voucher>[]);
        return TourHomeView(home: await home, interests: interests, vouchers: await vouchers);
      });
}

/// Bộ lọc tìm tour.
class TourFilter extends Equatable {
  const TourFilter({this.query = '', this.theme, this.maxPrice});

  final String query;
  final TravelTheme? theme;
  final double? maxPrice;

  TourFilter copyWith({String? query, TravelTheme? Function()? theme, double? Function()? maxPrice}) => TourFilter(
        query: query ?? this.query,
        theme: theme == null ? this.theme : theme(),
        maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
      );

  @override
  List<Object?> get props => [query, theme, maxPrice];
}

@injectable
class TourSearchCubit extends PagedCubit<Tour> {
  TourSearchCubit(this._search);

  final SearchTours _search;
  TourFilter filter = const TourFilter();

  Future<void> apply(TourFilter next) {
    filter = next;
    return load();
  }

  @override
  Future<Paged<Tour>> fetch({required int page, required int size}) =>
      _search(query: filter.query, theme: filter.theme, maxPrice: filter.maxPrice, page: page);
}
