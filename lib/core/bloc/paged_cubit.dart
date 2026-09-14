import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/app_exception.dart';
import '../network/paged.dart';
import 'load_state.dart';

/// Danh sách phân trang: tải trang đầu, nối thêm trang sau khi cuộn gần cuối.
class PagedState<T> extends Equatable {
  const PagedState({
    this.items = const [],
    this.status = ViewStatus.initial,
    this.error,
    this.page = 0,
    this.total = 0,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<T> items;
  final ViewStatus status;
  final String? error;
  final int page;
  final int total;
  final bool hasMore;
  final bool loadingMore;

  PagedState<T> copyWith({
    List<T>? items,
    ViewStatus? status,
    String? error,
    int? page,
    int? total,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      PagedState<T>(
        items: items ?? this.items,
        status: status ?? this.status,
        error: error ?? this.error,
        page: page ?? this.page,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );

  @override
  List<Object?> get props => [items, status, error, page, total, hasMore, loadingMore];
}

abstract class PagedCubit<T> extends Cubit<PagedState<T>> {
  PagedCubit({this.pageSize = 20}) : super(PagedState<T>());

  final int pageSize;

  @protected
  Future<Paged<T>> fetch({required int page, required int size});

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final result = await fetch(page: 0, size: pageSize);
      if (isClosed) return;
      emit(PagedState<T>(
        items: result.items,
        status: ViewStatus.success,
        page: result.page,
        total: result.totalElements,
        hasMore: result.hasMore,
      ));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          status: ViewStatus.failure,
          error: AppException.from(error).message,
        ));
      }
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.status != ViewStatus.success) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final result = await fetch(page: state.page + 1, size: pageSize);
      if (isClosed) return;
      emit(state.copyWith(
        items: [...state.items, ...result.items],
        page: result.page,
        total: result.totalElements,
        hasMore: result.hasMore,
        loadingMore: false,
      ));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(loadingMore: false, error: AppException.from(error).message));
      }
    }
  }
}
