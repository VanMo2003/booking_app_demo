import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/ai_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat.dart';

/// Một dòng hộp thư: ảnh/chữ cái đầu, tên người bên kia, tin cuối, giờ, số chưa đọc.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.showBranch = false,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  /// Hộp thư gộp nhiều cơ sở (chủ khách sạn): ghi rõ khách nhắn cơ sở nào.
  final bool showBranch;

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unread > 0;
    final preview = conversation.lastSentByMe
        ? '${ChatStrings.you}: ${conversation.lastMessage}'
        : conversation.lastMessage;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      borderColor: unread ? AppColors.primary.withValues(alpha: 0.35) : null,
      child: Row(
        children: [
          conversation.isCustomerView
              ? ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: AppNetworkImage(
                    path: conversation.counterpartImage,
                    width: 48,
                    height: 48,
                  ),
                )
              : AppAvatar(
                  name: conversation.customerName,
                  imagePath: conversation.customerImage,
                  size: 48,
                  tone: StatusTone.info,
                ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.counterpartName.isEmpty
                            ? ChatStrings.guest
                            : conversation.counterpartName,
                        style: AppTextStyles.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      Fmt.chatTime(conversation.lastMessageAt),
                      style: (unread ? AppTextStyles.captionStrong : AppTextStyles.caption)
                          .colored(unread ? AppColors.primary : AppColors.inkTertiary),
                    ),
                  ],
                ),
                if (!conversation.isCustomerView && conversation.needsStaff) ...[
                  const Gap(4),
                  const SoftTag(
                    label: AiStrings.needsStaff,
                    icon: Icons.support_agent_rounded,
                    tone: StatusTone.warning,
                  ),
                ],
                if (showBranch && !conversation.isCustomerView) ...[
                  const Gap(2),
                  IconText(
                    icon: Icons.storefront_outlined,
                    iconSize: 13,
                    text: conversation.hotelName,
                    style: AppTextStyles.caption,
                  ),
                ],
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        style: unread
                            ? AppTextStyles.bodySmall.weight(FontWeight.w600).colored(AppColors.ink)
                            : AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread) ...[
                      const Gap(AppSpacing.xs),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          ChatStrings.unreadCount(conversation.unread),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionStrong.colored(AppColors.onPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
