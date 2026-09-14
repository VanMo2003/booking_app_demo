import 'package:flutter/material.dart';

import '../bloc/load_state.dart';
import '../bloc/paged_cubit.dart';
import '../style/app_dimens.dart';
import '../text/app_strings.dart';
import '../text/error_strings.dart';
import 'app_button.dart';
import 'gap.dart';
import 'state_views.dart';

/// Danh sách theo [PagedState]: kéo để tải lại, cuộn gần cuối để tải thêm.
class PagedListView<T> extends StatelessWidget {
  const PagedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.filter,
    this.empty,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.bottomBarClearance),
  });

  final PagedState<T> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  /// Lọc tại chỗ trên các mục đã tải (tìm kiếm, lọc vai trò).
  final bool Function(T item)? filter;
  final Widget? empty;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      if (state.status == ViewStatus.failure) {
        return AppErrorView(message: state.error ?? ErrorStrings.unknown, onRetry: onRefresh);
      }
      if (state.status != ViewStatus.success) return const AppLoadingView();
    }
    final items = filter == null ? state.items : state.items.where(filter!).toList();
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 320) {
            onLoadMore();
          }
          return false;
        },
        child: items.isEmpty && !state.hasMore
            ? ListView(
                children: [
                  const Gap(AppSpacing.xxl),
                  empty ?? const AppEmptyView(title: AppStrings.emptyTitle),
                ],
              )
            : ListView.separated(
                padding: padding,
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                itemBuilder: (context, index) {
                  if (index < items.length) return itemBuilder(context, items[index]);
                  if (state.loadingMore) return const AppLoadingView();
                  if (!state.hasMore) return const SizedBox.shrink();
                  return Center(
                    child: AppButton.text(label: AppStrings.loadMore, onPressed: onLoadMore),
                  );
                },
              ),
      ),
    );
  }
}
