import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/hotel_usecases.dart';

class ExploreState extends Equatable {
  const ExploreState({
    required this.checkin,
    required this.checkout,
    this.status = ViewStatus.initial,
    this.hotels = const [],
    this.page = 0,
    this.hasMore = false,
    this.loadingMore = false,
    this.category,
    this.categories = const [],
    this.error,
    this.errorKind,
  });

  final DateTime checkin;
  final DateTime checkout;
  final ViewStatus status;
  final List<Hotel> hotels;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  /// `null` = tất cả loại hình.
  final String? category;

  /// Loại hình có trong dữ liệu (BE không có API liệt kê).
  final List<String> categories;
  final String? error;

  /// Nhóm lỗi để chọn component: mất mạng hay lỗi hệ thống.
  final AppErrorKind? errorKind;

  ExploreState copyWith({
    DateTime? checkin,
    DateTime? checkout,
    ViewStatus? status,
    List<Hotel>? hotels,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? category,
    bool clearCategory = false,
    List<String>? categories,
    String? error,
    AppErrorKind? errorKind,
  }) =>
      ExploreState(
        checkin: checkin ?? this.checkin,
        checkout: checkout ?? this.checkout,
        status: status ?? this.status,
        hotels: hotels ?? this.hotels,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        category: clearCategory ? null : category ?? this.category,
        categories: categories ?? this.categories,
        error: error,
        errorKind: errorKind,
      );

  @override
  List<Object?> get props => [
        checkin,
        checkout,
        status,
        hotels,
        page,
        hasMore,
        loadingMore,
        category,
        categories,
        error,
        errorKind,
      ];
}

@injectable
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._getPage, this._byCategory)
      : super(
          ExploreState(
            checkin: DateOnly.today(),
            checkout: DateOnly.addDays(DateOnly.today(), 1),
          ),
        );

  final GetHotelsPage _getPage;
  final GetHotelsByCategory _byCategory;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final category = state.category;
      if (category == null) {
        final page = await _getPage(0);
        emit(state.copyWith(
          status: ViewStatus.success,
          hotels: page.items,
          page: 0,
          hasMore: page.hasMore,
          categories: _categoriesOf(page.items),
        ));
      } else {
        final hotels = await _byCategory(category);
        emit(state.copyWith(
          status: ViewStatus.success,
          hotels: hotels,
          page: 0,
          hasMore: false,
        ));
      }
    } catch (error) {
      final exception = AppException.from(error);
      emit(state.copyWith(
        status: ViewStatus.failure,
        error: exception.message,
        errorKind: exception.kind,
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.loadingMore ||
        state.status != ViewStatus.success ||
        state.category != null) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _getPage(state.page + 1);
      final hotels = [...state.hotels, ...next.items];
      emit(state.copyWith(
        hotels: hotels,
        page: state.page + 1,
        hasMore: next.hasMore,
        loadingMore: false,
        categories: _categoriesOf(hotels),
      ));
    } catch (_) {
      emit(state.copyWith(loadingMore: false));
    }
  }

  void selectCategory(String? category) {
    if (category == state.category) return;
    emit(state.copyWith(category: category, clearCategory: category == null));
    load();
  }

  void setDates(DateTimeRange range) =>
      emit(state.copyWith(checkin: range.start, checkout: range.end));

  List<String> _categoriesOf(List<Hotel> hotels) => {
        ...state.categories,
        ...hotels.map((hotel) => hotel.category.trim()).where((c) => c.isNotEmpty),
      }.toList()
        ..sort();
}
