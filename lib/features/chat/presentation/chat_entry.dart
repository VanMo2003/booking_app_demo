import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/text/chat_strings.dart';
import '../../auth/presentation/session/auth_gate.dart';
import '../domain/usecases/chat_usecases.dart';
import 'chat_hub.dart';

extension ChatLauncher on BuildContext {
  /// Khách hàng mở cuộc trò chuyện với cơ sở (đăng nhập / tạo hồ sơ nếu cần).
  Future<void> openHotelChat(int hotelId) async {
    final customer = await ensureCustomer();
    if (customer == null || !mounted) return;
    final result = await AppAction.run(
      this,
      () => runAction(() => getIt<OpenConversation>()(hotelId)),
    );
    final conversation = result.value;
    if (conversation == null || !mounted) return;
    await rootRouter.push(ChatRoute(conversationId: conversation.id, initial: conversation));
  }
}

/// Biểu tượng tin nhắn kèm số chưa đọc — cho các tab của đội ngũ cơ sở.
class ChatInboxButton extends StatelessWidget {
  const ChatInboxButton({super.key, required this.hotelId, this.branchName});

  final int hotelId;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: ChatStrings.branchInbox,
      onPressed: () => context.rootRouter.push(
        BranchChatInboxRoute(hotelId: hotelId, branchName: branchName),
      ),
      icon: const ChatBadge(child: Icon(Icons.chat_bubble_outline_rounded)),
    );
  }
}

/// Chấm đỏ kèm số tin chưa đọc (lấy từ [ChatUnreadCubit]).
class ChatBadge extends StatelessWidget {
  const ChatBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<ChatUnreadCubit>().state;
    return Badge(
      isLabelVisible: unread > 0,
      backgroundColor: AppColors.danger,
      label: Text(ChatStrings.unreadCount(unread)),
      child: child,
    );
  }
}
