import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../../core/text/review_strings.dart';
import '../../ai/domain/usecases/ai_usecases.dart';
import '../../ai/presentation/ai_widgets.dart';
import '../domain/entities/review.dart';
import '../domain/usecases/feedback_usecases.dart';

/// Bảng cơ sở trả lời một đánh giá. Nút "AI soạn giúp" chỉ điền sẵn ô nhập — câu trả lời chỉ được
/// đăng khi quản lý tự bấm đăng, nên không bao giờ có chữ nào của AI lên trang mà người chưa đọc.
/// Trả về đánh giá đã cập nhật khi đăng xong, null khi quản lý đóng bảng.
Future<Review?> showReviewReply(BuildContext context, Review review) {
  return showModalBottomSheet<Review>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _ReviewReplySheet(review: review),
    ),
  );
}

class _ReviewReplySheet extends StatefulWidget {
  const _ReviewReplySheet({required this.review});

  final Review review;

  @override
  State<_ReviewReplySheet> createState() => _ReviewReplySheetState();
}

class _ReviewReplySheetState extends State<_ReviewReplySheet> {
  late final TextEditingController _reply = TextEditingController(text: widget.review.reply ?? '');
  List<String> _points = const [];
  String? _error;
  bool _drafting = false;
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _draft() async {
    setState(() {
      _drafting = true;
      _error = null;
    });
    final result = await runAction(() => getIt<DraftReviewReply>()(widget.review.id));
    if (!mounted) return;
    setState(() {
      _drafting = false;
      _error = result.error;
      final draft = result.value;
      if (draft != null) {
        _reply.text = draft.draft;
        _points = draft.points;
      }
    });
  }

  Future<void> _send() async {
    final reply = _reply.text.trim();
    if (reply.isEmpty) {
      setState(() => _error = AiStrings.replyDraftEmpty);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<ReplyToReview>()(reviewId: widget.review.id, reply: reply),
    );
    if (!mounted) return;
    if (result.error != null) {
      setState(() {
        _sending = false;
        _error = result.error;
      });
      return;
    }
    Navigator.of(context).pop(result.value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AiStrings.replyDraftTitle, style: AppTextStyles.subtitle),
            const Gap(4),
            Text(AiStrings.replyDraftHint, style: AppTextStyles.caption),
            const Gap(AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                  const Gap(4),
                  Text('${widget.review.rating}/5', style: AppTextStyles.bodyStrong),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.review.comments ?? ReviewStrings.anonymous,
                      style: AppTextStyles.bodySmall,
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
            if (_points.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              const GroupLabel(AiStrings.replyDraftPoints),
              const Gap(4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final point in _points) SoftTag(label: point)],
              ),
            ],
            const Gap(AppSpacing.sm),
            AppTextField(controller: _reply, maxLines: 5, minLines: 3),
            const Gap(AppSpacing.xs),
            AiEnabled(
              child: AppButton.text(
                label: AiStrings.replyDraftAction,
                size: AppButtonSize.small,
                icon: Icons.auto_awesome_rounded,
                loading: _drafting,
                onPressed: _draft,
              ),
            ),
            if (_error != null) ...[
              const Gap(AppSpacing.xs),
              NoticeBanner(text: _error!, tone: StatusTone.danger),
            ],
            const Gap(AppSpacing.sm),
            AppButton(
              label: AiStrings.replyDraftSend,
              size: AppButtonSize.small,
              icon: Icons.send_rounded,
              loading: _sending,
              expand: true,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
