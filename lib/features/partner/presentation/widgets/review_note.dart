import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';

/// Ghi chú xét duyệt: lý do từ chối (đỏ) hoặc lý do của lần từ chối trước (xanh).
class ReviewNote extends StatelessWidget {
  const ReviewNote({
    super.key,
    required this.title,
    required this.text,
    this.tone = StatusTone.danger,
    this.caption,
  });

  final String title;
  final String text;
  final StatusTone tone;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.smAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tone == StatusTone.danger
                    ? Icons.report_gmailerrorred_rounded
                    : Icons.history_rounded,
                size: 18,
                color: colors.foreground,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.captionStrong.colored(colors.foreground),
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(text, style: AppTextStyles.body.colored(AppColors.ink)),
          if (caption != null) ...[
            const Gap(4),
            Text(caption!, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}
