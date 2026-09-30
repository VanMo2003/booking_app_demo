import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paged_cubit.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../ai/presentation/ai_widgets.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../domain/entities/chat.dart';
import 'conversation_tile.dart';
import 'conversations_cubit.dart';

/// Tab Tin nhắn — của khách hàng (các khách sạn đã nhắn) và của chủ khách sạn
/// (khách nhắn tới mọi cơ sở trong chuỗi).
@RoutePage()
class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.select((SessionCubit cubit) => cubit.state.session);
    if (session == null) {
      return AppPage(
        title: ChatStrings.title,
        automaticallyImplyLeading: false,
        body: LoginPromptView(
          title: AuthStrings.loginRequiredTitle,
          message: ChatStrings.loginPrompt,
          icon: Icons.chat_bubble_outline_rounded,
          onLogin: () => context.rootRouter.push<bool>(LoginRoute(returnResult: true)),
          onRegister: () => context.rootRouter.push<bool>(RegisterRoute(returnResult: true)),
        ),
      );
    }
    if (session.needsCustomerProfile) {
      return AppPage(
        title: ChatStrings.title,
        automaticallyImplyLeading: false,
        body: AppEmptyView(
          icon: Icons.badge_outlined,
          title: ChatStrings.profileRequired,
          message: ChatStrings.profileRequiredHint,
          addLabel: ChatStrings.completeProfile,
          addIcon: Icons.arrow_forward_rounded,
          onAdd: () => context.rootRouter.push<bool>(ProfileSetupRoute(returnResult: true)),
        ),
      );
    }
    final asCustomer = session.role == Role.customer;
    return BlocProvider(
      key: ValueKey(session.username),
      create: (_) => getIt<ConversationsCubit>()..start(asCustomer: asCustomer),
      child: AppPage(
        title: ChatStrings.title,
        subtitle: asCustomer ? null : ChatStrings.allBranches,
        automaticallyImplyLeading: false,
        body: ConversationListView(asCustomer: asCustomer, showBranch: !asCustomer),
      ),
    );
  }
}

/// Tin nhắn khách gửi tới một cơ sở — mở từ không gian làm việc của cơ sở.
@RoutePage()
class BranchChatInboxScreen extends StatelessWidget {
  const BranchChatInboxScreen({super.key, required this.hotelId, this.branchName});

  final int hotelId;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationsCubit>()..start(asCustomer: false, hotelId: hotelId),
      child: AppPage(
        title: ChatStrings.branchInbox,
        subtitle: branchName,
        body: Column(
          children: [
            AiAutoReplyBar(hotelId: hotelId),
            const Expanded(child: ConversationListView(asCustomer: false)),
          ],
        ),
      ),
    );
  }
}

class ConversationListView extends StatelessWidget {
  const ConversationListView({super.key, required this.asCustomer, this.showBranch = false});

  final bool asCustomer;
  final bool showBranch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, PagedState<Conversation>>(
      builder: (context, state) {
        final cubit = context.read<ConversationsCubit>();
        return PagedListView<Conversation>(
          state: state,
          onRefresh: cubit.load,
          onLoadMore: cubit.loadMore,
          empty: AppEmptyView(
            icon: Icons.forum_outlined,
            title: asCustomer ? ChatStrings.emptyCustomer : ChatStrings.emptyHotel,
            message: asCustomer ? ChatStrings.emptyCustomerHint : ChatStrings.emptyHotelHint,
          ),
          itemBuilder: (context, conversation) => ConversationTile(
            conversation: conversation,
            showBranch: showBranch,
            onTap: () => context.rootRouter.push(
              ChatRoute(conversationId: conversation.id, initial: conversation),
            ),
          ),
        );
      },
    );
  }
}
