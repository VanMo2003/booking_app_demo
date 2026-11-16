import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

/// Bảng "AI tóm tắt hội thoại" cho nhân viên: khách cần gì, còn việc gì treo, nên làm gì tiếp.
/// Không gửi gì cho khách — chỉ là ghi chú để người trả lời nắm nhanh một hội thoại dài.
Future<void> showChatSummary(BuildContext context, int conversationId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _ChatSummarySheet(conversationId: conversationId),
  );
}

class _ChatSummarySheet extends StatefulWidget {
  const _ChatSummarySheet({required this.conversationId});

  final int conversationId;

  @override
  State<_ChatSummarySheet> createState() => _ChatSummarySheetState();
}

class _ChatSummarySheetState extends State<_ChatSummarySheet> {
  ChatSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final result = await runAction(() => getIt<GetChatSummary>()(widget.conversationId));
    if (!mounted) return;
    setState(() {
      _summary = result.value;
      _error = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                const Gap(AppSpacing.xs),
                Expanded(child: Text(AiStrings.summaryTitle, style: AppTextStyles.subtitle)),
                if (summary != null)
                  StatusBadge(
                    label: AiStrings.summaryUrgency(summary.urgency),
                    tone: switch (summary.urgency) {
                      ChatUrgency.high => StatusTone.danger,
                      ChatUrgency.normal => StatusTone.brand,
                      ChatUrgency.low => StatusTone.neutral,
                    },
                    dense: true,
                  ),
              ],
            ),
            const Gap(AppSpacing.sm),
            if (_error != null)
              AppFailureView(message: _error!, onRetry: _load, compact: true)
            else if (summary == null)
              const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: AppLoadingView())
            else if (summary.isEmpty)
              const AppEmptyView(icon: Icons.forum_outlined, title: AiStrings.summaryEmpty, compact: true)
            else ...[
              Text(AiStrings.summaryFrom(summary.messageCount), style: AppTextStyles.caption),
              if (summary.waitingOnHotel) ...[
                const Gap(AppSpacing.xs),
                const NoticeBanner(
                  text: AiStrings.summaryWaiting,
                  icon: Icons.schedule_rounded,
                  tone: StatusTone.warning,
                ),
              ],
              if (summary.needsStaff) ...[
                const Gap(AppSpacing.xs),
                NoticeBanner(
                  text: AiStrings.handedOff(summary.handoffReason),
                  icon: Icons.support_agent_rounded,
                  tone: StatusTone.warning,
                ),
              ],
              if (summary.summary != null) ...[
                const Gap(AppSpacing.sm),
                Text(summary.summary!, style: AppTextStyles.bodyMedium),
              ],
              if (summary.openItems.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                const GroupLabel(AiStrings.summaryOpen),
                for (final item in summary.openItems)
                  IconText(
                    icon: Icons.radio_button_unchecked_rounded,
                    iconColor: AppColors.warning,
                    text: item,
                    maxLines: 2,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
              if (summary.nextSteps.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                const GroupLabel(AiStrings.summaryNext),
                for (final step in summary.nextSteps)
                  IconText(
                    icon: Icons.arrow_forward_rounded,
                    iconColor: AppColors.primary,
                    text: step,
                    maxLines: 2,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
              const Gap(AppSpacing.xs),
              Text(AiStrings.summaryNote, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
