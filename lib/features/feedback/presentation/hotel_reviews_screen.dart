import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/network/paged.dart';
import '../../../core/style/style.dart';
import '../../../core/text/review_strings.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/review.dart';
import '../domain/usecases/feedback_usecases.dart';
import 'review_reply_sheet.dart';

/// Đánh giá đã tải: danh sách đang hiện, tổng số và còn trang nào nữa không.
class ReviewList {
  const ReviewList({required this.items, required this.total, required this.lastPage});

  final List<Review> items;
  final int total;
  final int lastPage;

  bool get hasMore => items.length < total;
}

@injectable
class HotelReviewsCubit extends LoadCubit<ReviewList> {
  HotelReviewsCubit(this._reviews);

  final GetHotelReviews _reviews;
  late int _hotelId;
  bool _loadingMore = false;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() async {
        final page = await _reviews(hotelId: _hotelId);
        return _toList(page, const []);
      });

  /// Trang tiếp theo được nối vào danh sách đang hiện, không thay thế nó.
  Future<void> loadMore() async {
    final current = state.data;
    if (_loadingMore || current == null || !current.hasMore) return;
    _loadingMore = true;
    try {
      final page = await _reviews(hotelId: _hotelId, page: current.lastPage + 1);
      if (!isClosed) emit(state.toSuccess(_toList(page, current.items)));
    } catch (error) {
      if (!isClosed) emit(state.toError(error));
    } finally {
      _loadingMore = false;
    }
  }

  /// Sau khi cơ sở trả lời: thay đúng một dòng, khỏi tải lại cả danh sách.
  void replaceReview(Review updated) {
    final current = state.data;
    if (current == null) return;
    emit(state.toSuccess(ReviewList(
      items: current.items.map((review) => review.id == updated.id ? updated : review).toList(),
      total: current.total,
      lastPage: current.lastPage,
    )));
  }

  static ReviewList _toList(Paged<Review> page, List<Review> before) => ReviewList(
        items: [...before, ...page.items],
        total: page.totalElements,
        lastPage: page.page,
      );
}

/// Đánh giá của khách về một cơ sở. Ai cũng xem được; [canReply] mở thêm nút trả lời cho
/// chủ chuỗi và quản lý cơ sở — chỉ những màn trong khu làm việc truyền true.
@RoutePage()
class HotelReviewsScreen extends StatelessWidget {
  const HotelReviewsScreen({
    super.key,
    required this.hotelId,
    this.subtitle,
    this.canReply = false,
  });

  final int hotelId;
  final String? subtitle;
  final bool canReply;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HotelReviewsCubit>()..start(hotelId),
      child: Builder(
        builder: (context) => AppPage(
          title: ReviewStrings.title,
          subtitle: subtitle,
          body: BlocBuilder<HotelReviewsCubit, LoadState<ReviewList>>(
            builder: (context, state) => LoadStateView<ReviewList>(
              state: state,
              onRetry: context.read<HotelReviewsCubit>().load,
              builder: (context, reviews) => reviews.items.isEmpty
                  ? const AppEmptyView(message: ReviewStrings.empty, showButton: false)
                  : ListView(
                      padding: AppSpacing.page,
                      children: [
                        Text(ReviewStrings.count(reviews.total), style: AppTextStyles.bodySmall),
                        const Gap(AppSpacing.sm),
                        for (final review in reviews.items) ...[
                          ReviewCard(
                            review: review,
                            onReply: canReply
                                ? () async {
                                    final updated = await showReviewReply(context, review);
                                    if (updated != null && context.mounted) {
                                      context.read<HotelReviewsCubit>().replaceReview(updated);
                                    }
                                  }
                                : null,
                          ),
                          const Gap(AppSpacing.sm),
                        ],
                        if (reviews.hasMore)
                          AppButton.secondary(
                            label: ReviewStrings.more,
                            size: AppButtonSize.small,
                            onPressed: context.read<HotelReviewsCubit>().loadMore,
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Một đánh giá: sao, nhận xét, và câu trả lời của cơ sở nếu đã có.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.onReply});

  final Review review;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
              const Gap(4),
              Text('${review.rating}/5', style: AppTextStyles.bodyStrong),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  review.customerName ?? ReviewStrings.anonymous,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (review.reviewDate != null)
                Text(Fmt.date(review.reviewDate), style: AppTextStyles.caption),
            ],
          ),
          if (review.comments != null && review.comments!.isNotEmpty) ...[
            const Gap(AppSpacing.xs),
            Text(review.comments!, style: AppTextStyles.bodyMedium),
          ],
          if (review.answered) ...[
            const Gap(AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: AppColors.lineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded, size: 14, color: AppColors.inkTertiary),
                      const Gap(4),
                      Expanded(child: Text(ReviewStrings.replyFrom, style: AppTextStyles.caption)),
                      if (review.replyAt != null)
                        Text(Fmt.date(review.replyAt), style: AppTextStyles.caption),
                    ],
                  ),
                  const Gap(4),
                  Text(review.reply!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
          if (onReply != null) ...[
            const Gap(AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton.text(
                label: review.answered ? ReviewStrings.editReply : ReviewStrings.reply,
                size: AppButtonSize.small,
                icon: Icons.reply_rounded,
                onPressed: onReply,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Thẻ gọn trong trang chi tiết cơ sở: vài đánh giá mới nhất và lối sang xem tất cả.
class HotelReviewsPreview extends StatefulWidget {
  const HotelReviewsPreview({super.key, required this.hotelId, this.hotelName});

  final int hotelId;
  final String? hotelName;

  @override
  State<HotelReviewsPreview> createState() => _HotelReviewsPreviewState();
}

class _HotelReviewsPreviewState extends State<HotelReviewsPreview> {
  List<Review>? _reviews;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await runAction(() => getIt<GetHotelReviews>()(hotelId: widget.hotelId, size: 2));
    if (!mounted) return;
    setState(() {
      _reviews = result.value?.items;
      _total = result.value?.totalElements ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    // Chưa có đánh giá nào thì không chiếm chỗ trong trang.
    if (reviews == null || reviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.xl),
        SectionHeader(
          title: ReviewStrings.title,
          trailing: Text(ReviewStrings.count(_total), style: AppTextStyles.bodySmall),
        ),
        const Gap(AppSpacing.xs),
        for (final review in reviews) ...[
          ReviewCard(review: review),
          const Gap(AppSpacing.sm),
        ],
        AppButton.text(
          label: ReviewStrings.seeAll,
          size: AppButtonSize.small,
          icon: Icons.chevron_right_rounded,
          onPressed: () => context.router.push(
            HotelReviewsRoute(hotelId: widget.hotelId, subtitle: widget.hotelName),
          ),
        ),
      ],
    );
  }
}
