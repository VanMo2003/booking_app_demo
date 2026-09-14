import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/booking_strings.dart';
import '../domain/usecases/feedback_usecases.dart';

/// Đánh giá sau khi đơn hoàn tất.
@RoutePage()
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.customerId,
    required this.hotelName,
  });

  final int bookingId;
  final int customerId;
  final String hotelName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _comment = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final result = await runAction(
      () => getIt<SubmitReview>()(
        bookingId: widget.bookingId,
        customerId: widget.customerId,
        rating: _rating,
        comments: _comment.text,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isSuccess) {
      AppToast.success(context, BookingStrings.reviewThanks);
      await context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: BookingStrings.reviewTitle,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const Gap(AppSpacing.md),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rate_review_rounded, size: 34, color: AppColors.accent),
            ),
          ),
          const Gap(AppSpacing.md),
          Text(BookingStrings.reviewHeadline, style: AppTextStyles.headline, textAlign: TextAlign.center),
          if (widget.hotelName.isNotEmpty) ...[
            const Gap(4),
            Text(widget.hotelName, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
          const Gap(AppSpacing.lg),
          Center(child: RatingInput(value: _rating, onChanged: (value) => setState(() => _rating = value))),
          Text(
            BookingStrings.ratingLabels[_rating - 1],
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.colored(AppColors.warning),
          ),
          const Gap(AppSpacing.xl),
          AppTextField(
            controller: _comment,
            label: BookingStrings.reviewComment,
            hint: BookingStrings.reviewCommentHint,
            minLines: 4,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: BookingStrings.reviewSubmit,
          expand: true,
          loading: _submitting,
          onPressed: _submit,
        ),
      ),
    );
  }
}
