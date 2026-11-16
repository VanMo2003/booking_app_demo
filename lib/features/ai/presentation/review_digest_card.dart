import 'package:flutter/material.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

/// Thẻ "Khách nói gì về cơ sở này" trong trang chi tiết cơ sở: AI tóm tắt từ chính đánh giá của khách,
/// kèm phổ sao. Cơ sở còn ít đánh giá hoặc máy chủ chưa bật AI thì thẻ tự ẩn, nên gọi được ở mọi nơi.
class ReviewDigestCard extends StatefulWidget {
  const ReviewDigestCard({super.key, required this.hotelId});

  final int hotelId;

  @override
  State<ReviewDigestCard> createState() => _ReviewDigestCardState();
}

class _ReviewDigestCardState extends State<ReviewDigestCard> {
  ReviewDigest? _digest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ReviewDigestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hotelId != widget.hotelId) _load();
  }

  Future<void> _load() async {
    if (!getIt.isRegistered<AiAvailability>() || !getIt<AiAvailability>().enabled.value) return;
    try {
      final digest = await getIt<GetReviewDigest>()(widget.hotelId);
      if (mounted && digest.available) setState(() => _digest = digest);
    } catch (_) {
      // Chỉ là phần phụ của trang: lỗi thì không hiện gì.
    }
  }

  @override
  Widget build(BuildContext context) {
    final digest = _digest;
    if (digest == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: AiStrings.digestTitle),
          const Gap(AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                    const Gap(AppSpacing.xs),
                    Expanded(
                      child: Text(AiStrings.digestFrom(digest.reviewCount), style: AppTextStyles.caption),
                    ),
                    if (digest.averageRating > 0) RatingStars(rating: digest.averageRating, size: 14),
                  ],
                ),
                if (digest.summary != null) ...[
                  const Gap(AppSpacing.sm),
                  Text(digest.summary!, style: AppTextStyles.bodyMedium),
                ],
                if (digest.pros.isNotEmpty) ...[
                  const Gap(AppSpacing.sm),
                  const GroupLabel(AiStrings.digestPros),
                  for (final item in digest.pros)
                    IconText(
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: AppColors.success,
                      text: item,
                      maxLines: 2,
                      style: AppTextStyles.bodySmall,
                    ),
                ],
                if (digest.cons.isNotEmpty) ...[
                  const Gap(AppSpacing.sm),
                  const GroupLabel(AiStrings.digestCons),
                  for (final item in digest.cons)
                    IconText(
                      icon: Icons.remove_circle_outline_rounded,
                      iconColor: AppColors.warning,
                      text: item,
                      maxLines: 2,
                      style: AppTextStyles.bodySmall,
                    ),
                ],
                if (digest.busiestRating > 0) ...[
                  const Gap(AppSpacing.sm),
                  _RatingBars(digest: digest),
                ],
                const Gap(AppSpacing.xs),
                Text(AiStrings.digestNote, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Phổ sao: mỗi mức một thanh, dài theo tỉ lệ so với mức nhiều đánh giá nhất.
class _RatingBars extends StatelessWidget {
  const _RatingBars({required this.digest});

  final ReviewDigest digest;

  @override
  Widget build(BuildContext context) {
    final busiest = digest.busiestRating;
    return Column(
      children: [
        for (var stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(AiStrings.digestStars(stars), style: AppTextStyles.caption),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: busiest == 0 ? 0 : _count(stars) / busiest,
                      minHeight: 6,
                      backgroundColor: AppColors.primarySoft,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${_count(stars)}',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _count(int stars) =>
      stars - 1 < digest.ratingCounts.length ? digest.ratingCounts[stars - 1] : 0;
}
