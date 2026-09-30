import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/ai_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat.dart';

/// Bong bóng tin. Tin của phía mình nằm bên phải, nền màu chủ đạo. Các tin liền
/// nhau của cùng người gửi được gom nhóm: tên chỉ ở tin đầu, giờ chỉ ở tin cuối.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.content,
    required this.mine,
    this.senderLabel,
    this.time,
    this.firstInGroup = true,
    this.lastInGroup = true,
    this.pending = false,
    this.failed = false,
    this.aiGenerated = false,
    this.onTap,
  });

  factory MessageBubble.message(
    ChatMessage message, {
    Key? key,
    required bool mine,
    required bool showSender,
    required bool firstInGroup,
    required bool lastInGroup,
  }) =>
      MessageBubble(
        key: key,
        content: message.content,
        mine: mine,
        senderLabel: showSender ? senderLabelOf(message) : null,
        time: lastInGroup ? Fmt.time(message.sentAt) : null,
        firstInGroup: firstInGroup,
        lastInGroup: lastInGroup,
        aiGenerated: message.aiGenerated,
      );

  /// "Lan · Nhân viên" — khách biết ai của cơ sở đang trả lời; tin do AI viết ghi rõ "Trợ lý AI".
  static String senderLabelOf(ChatMessage message) {
    if (message.aiGenerated) return AiStrings.assistantName;
    final role = message.senderSide == ChatSide.hotel ? message.senderRole?.label : null;
    final name = message.senderName.isEmpty ? ChatStrings.guest : message.senderName;
    return role == null ? name : '$name · $role';
  }

  final String content;
  final bool mine;
  final String? senderLabel;
  final String? time;
  final bool firstInGroup;
  final bool lastInGroup;
  final bool pending;
  final bool failed;
  final bool aiGenerated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const round = Radius.circular(18);
    const tight = Radius.circular(5);
    final radius = BorderRadius.only(
      topLeft: !mine && !firstInGroup ? tight : round,
      bottomLeft: !mine && !lastInGroup ? tight : round,
      topRight: mine && !firstInGroup ? tight : round,
      bottomRight: mine && !lastInGroup ? tight : round,
    );
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final status = failed
        ? ChatStrings.failed
        : pending
            ? ChatStrings.sending
            : time;
    return Padding(
      padding: EdgeInsets.only(top: firstInGroup ? AppSpacing.xs : 2),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (senderLabel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
              child: aiGenerated
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(senderLabel!, style: AppTextStyles.captionStrong.colored(AppColors.accent)),
                      ],
                    )
                  : Text(senderLabel!, style: AppTextStyles.caption),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Material(
              color: failed
                  ? AppColors.dangerSoft
                  : mine
                      ? AppColors.primary.withValues(alpha: pending ? 0.7 : 1)
                      : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: mine && !failed ? BorderSide.none : const BorderSide(color: AppColors.lineSoft),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: SelectableText(
                    content,
                    onTap: onTap,
                    style: AppTextStyles.body.colored(
                      failed
                          ? AppColors.danger
                          : mine
                              ? AppColors.onPrimary
                              : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 3, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (failed) ...[
                    const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.danger),
                    const SizedBox(width: 4),
                  ] else if (pending) ...[
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.inkTertiary),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    status,
                    style: AppTextStyles.caption.colored(failed ? AppColors.danger : AppColors.inkTertiary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Mốc ngày giữa các tin: "Hôm nay", "Hôm qua", "T5, 02/10".
class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider(this.day, {super.key});

  final DateTime day;

  static String label(DateTime day, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final days = today.difference(DateUtils.dateOnly(day)).inDays;
    if (days == 0) return ChatStrings.today;
    if (days == 1) return ChatStrings.yesterday;
    return day.year == today.year ? Fmt.weekdayDate(day) : Fmt.date(day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceSunk,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(label(day), style: AppTextStyles.captionStrong.colored(AppColors.inkSecondary)),
        ),
      ),
    );
  }
}
