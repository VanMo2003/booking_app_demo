import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/ai_strings.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/chat_strings.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../ai/domain/usecases/ai_usecases.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../domain/entities/chat.dart';
import '../../services/chat_socket.dart';
import 'chat_cubit.dart';
import 'message_bubble.dart';

/// Một cuộc trò chuyện — dùng chung cho khách hàng và đội ngũ cơ sở.
@RoutePage()
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.conversationId, this.initial, this.draft});

  final int conversationId;

  /// Bản tóm tắt đã có ở danh sách, để tiêu đề hiện ngay trong lúc tải.
  final Conversation? initial;

  /// Nội dung điền sẵn vào ô nhập (ví dụ câu hỏi về một tour).
  final String? draft;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatCubit>()..start(conversationId, initial: initial),
      child: _ChatView(draft: draft),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({this.draft});

  final String? draft;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final conversation = state.conversation;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: conversation == null ? null : _ChatTitle(conversation: conversation),
            actions: [
              if (conversation != null && conversation.counterpartPhone.isNotEmpty)
                IconButton(
                  tooltip: AppStrings.call,
                  onPressed: () => ExternalActions.call(conversation.counterpartPhone),
                  icon: const Icon(Icons.call_outlined),
                ),
              const SizedBox(width: AppSpacing.xxs),
            ],
          ),
          body: Column(
            children: [
              const _ConnectionBanner(),
              if (conversation != null && !conversation.isCustomerView && conversation.needsStaff)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: NoticeBanner(
                    text: AiStrings.handedOff(conversation.handoffReason),
                    icon: Icons.support_agent_rounded,
                    tone: StatusTone.warning,
                  ),
                ),
              Expanded(
                child: switch (state.status) {
                  ViewStatus.failure when state.isEmpty => AppFailureView(
                      message: state.error ?? '',
                      kind: state.errorKind,
                      onRetry: cubit.retry,
                    ),
                  ViewStatus.success || ViewStatus.failure => state.isEmpty && conversation != null
                      ? _EmptyChat(conversation: conversation, onPick: cubit.send)
                      : _MessageList(state: state),
                  _ => const AppLoadingView(),
                },
              ),
              if (conversation != null && state.status == ViewStatus.success)
                _Composer(
                  onSend: cubit.send,
                  initialText: draft,
                  // Chỉ đội ngũ cơ sở được AI soạn nháp; khách thì không.
                  suggestFor: conversation.isCustomerView ? null : conversation.id,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final customerView = conversation.isCustomerView;
    final subtitle = customerView
        ? conversation.hotelAddress
        : [conversation.customerPhone, conversation.hotelName].where((s) => s.isNotEmpty).join(' · ');
    return InkWell(
      // Khách chạm tiêu đề để xem lại trang cơ sở.
      onTap: customerView
          ? () => context.router.push(HotelDetailRoute(hotelId: conversation.hotelId))
          : null,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            customerView
                ? AppNetworkImage(
                    path: conversation.hotelImage,
                    width: 38,
                    height: 38,
                    borderRadius: AppRadius.smAll,
                  )
                : AppAvatar(
                    name: conversation.customerName,
                    imagePath: conversation.customerImage,
                    size: 38,
                    tone: StatusTone.info,
                  ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    conversation.counterpartName.isEmpty
                        ? ChatStrings.guest
                        : conversation.counterpartName,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dải báo mất kết nối realtime. Gửi tin vẫn chạy (REST); chỉ tin đến bị chậm.
class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChatConnection>(
      valueListenable: getIt<ChatSocket>().connection,
      builder: (context, connection, _) => AnimatedSize(
        duration: AppDurations.normal,
        child: connection == ChatConnection.online
            ? const SizedBox(width: double.infinity)
            : Container(
                width: double.infinity,
                color: AppColors.warningSoft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.6, color: AppColors.warning),
                    ),
                    const Gap(AppSpacing.xs),
                    Expanded(
                      child: Text(
                        ChatStrings.reconnecting,
                        style: AppTextStyles.caption.colored(AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

sealed class _Item {
  const _Item();
}

class _PendingItem extends _Item {
  const _PendingItem(this.message);

  final PendingMessage message;
}

class _MessageItem extends _Item {
  const _MessageItem(this.message, {required this.first, required this.last, required this.showSender});

  final ChatMessage message;
  final bool first;
  final bool last;
  final bool showSender;
}

class _DayItem extends _Item {
  const _DayItem(this.day);

  final DateTime day;
}

class _OlderItem extends _Item {
  const _OlderItem();
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state});

  final ChatState state;

  static bool _sameGroup(ChatMessage? a, ChatMessage b) =>
      a != null &&
      a.senderSide == b.senderSide &&
      a.senderAccountId == b.senderAccountId &&
      DateUtils.isSameDay(a.sentAt, b.sentAt) &&
      a.sentAt.difference(b.sentAt).inMinutes.abs() < 5;

  /// Danh sách đảo ngược: phần tử 0 nằm dưới cùng (mới nhất).
  static List<_Item> itemsOf(ChatState state, String? myAccountId) {
    final conversation = state.conversation!;
    final items = <_Item>[for (final pending in state.pending) _PendingItem(pending)];
    final messages = state.messages;
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final newer = i > 0 ? messages[i - 1] : null;
      final older = i + 1 < messages.length ? messages[i + 1] : null;
      final first = !_sameGroup(older, message);
      final mine = message.senderSide == conversation.mySide;
      // Khách thấy ai của cơ sở đang trả lời; nhân viên thấy tin của đồng nghiệp.
      final showSender = first &&
          (conversation.isCustomerView
              ? !mine
              : mine && message.senderAccountId != myAccountId);
      items.add(_MessageItem(
        message,
        first: first,
        last: !_sameGroup(newer, message),
        showSender: showSender,
      ));
      final dayChanges =
          older == null ? !state.hasOlder : !DateUtils.isSameDay(older.sentAt, message.sentAt);
      if (dayChanges) items.add(_DayItem(message.sentAt));
    }
    if (state.hasOlder) items.add(const _OlderItem());
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final myAccountId = context.select((SessionCubit c) => c.state.session?.resolvedAccountId);
    final conversation = state.conversation!;
    final items = itemsOf(state, myAccountId);
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: items.length,
      itemBuilder: (context, index) => switch (items[index]) {
        _PendingItem(:final message) => MessageBubble(
            key: ValueKey(message.localId),
            content: message.content,
            mine: true,
            pending: !message.failed,
            failed: message.failed,
            onTap: message.failed ? () => _pendingActions(context, cubit, message) : null,
          ),
        _MessageItem(:final message, :final first, :final last, :final showSender) =>
          MessageBubble.message(
            message,
            key: ValueKey(message.id),
            mine: message.senderSide == conversation.mySide,
            showSender: showSender,
            firstInGroup: first,
            lastInGroup: last,
          ),
        _DayItem(:final day) => ChatDateDivider(day),
        _OlderItem() => _OlderLoader(state: state, onLoad: cubit.loadOlder),
      },
    );
  }

  Future<void> _pendingActions(BuildContext context, ChatCubit cubit, PendingMessage message) async {
    final action = await AppDialogs.choose<bool>(
      context,
      title: ChatStrings.failed,
      choices: const [
        AppChoice(value: true, label: ChatStrings.retry, icon: Icons.refresh_rounded),
        AppChoice(
          value: false,
          label: ChatStrings.discard,
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (action == true) {
      await cubit.resend(message.localId);
    } else if (action == false) {
      cubit.discard(message.localId);
    }
  }
}

/// Đầu danh sách (trên cùng): tự tải tin cũ hơn khi cuộn tới.
class _OlderLoader extends StatelessWidget {
  const _OlderLoader({required this.state, required this.onLoad});

  final ChatState state;
  final Future<void> Function() onLoad;

  @override
  Widget build(BuildContext context) {
    if (state.olderFailed) {
      return Center(
        child: AppButton.text(
          label: ChatStrings.loadOlderFailed,
          icon: Icons.refresh_rounded,
          onPressed: onLoad,
        ),
      );
    }
    if (!state.loadingOlder) WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.conversation, required this.onPick});

  final Conversation conversation;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (!conversation.isCustomerView) {
      return const AppEmptyView(
        icon: Icons.forum_outlined,
        title: ChatStrings.hotelEmptyHint,
        compact: true,
      );
    }
    return ListView(
      padding: AppSpacing.page,
      children: [
        const Gap(AppSpacing.xl),
        Center(
          child: AppNetworkImage(
            path: conversation.hotelImage,
            width: 72,
            height: 72,
            borderRadius: AppRadius.mdAll,
          ),
        ),
        const Gap(AppSpacing.md),
        Text(
          ChatStrings.greeting(conversation.hotelName),
          textAlign: TextAlign.center,
          style: AppTextStyles.title,
        ),
        const Gap(AppSpacing.xs),
        Text(
          ChatStrings.greetingHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const Gap(AppSpacing.lg),
        for (final text in ChatStrings.quickReplies) ...[
          Center(
            child: ActionChip(
              label: Text(text),
              avatar: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              onPressed: () => onPick(text),
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.onSend, this.suggestFor, this.initialText});

  final ValueChanged<String> onSend;
  final String? initialText;

  /// Id cuộc trò chuyện để xin AI soạn nháp; `null` = không có nút gợi ý.
  final int? suggestFor;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  static const _maxLength = 2000;
  late final _controller = TextEditingController(text: widget.initialText);
  bool _suggesting = false;
  String? _aiNote;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _maxLength) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _aiNote = null);
  }

  Future<void> _suggest() async {
    setState(() => _suggesting = true);
    final result = await runAction(() => getIt<SuggestChatReply>()(widget.suggestFor!));
    if (!mounted) return;
    setState(() => _suggesting = false);
    final suggestion = result.value;
    if (suggestion == null) {
      AppToast.error(context, result.error!);
      return;
    }
    _controller.text = suggestion.content;
    _controller.selection = TextSelection.collapsed(offset: suggestion.content.length);
    setState(() {
      _aiNote = suggestion.needsStaff && suggestion.handoffReason != null
          ? AiStrings.suggestionHandoff(suggestion.handoffReason!)
          : AiStrings.suggestionNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.lineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final text = value.text.trim();
              final tooLong = text.length > _maxLength;
              final row = Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.suggestFor != null)
                    ValueListenableBuilder<bool>(
                      valueListenable: getIt<AiAvailability>().enabled,
                      builder: (context, enabled, _) => !enabled
                          ? const SizedBox.shrink()
                          : IconButton(
                              tooltip: AiStrings.suggest,
                              onPressed: _suggesting ? null : _suggest,
                              icon: _suggesting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
                            ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: ChatStrings.inputHint,
                        isDense: true,
                        errorText: tooLong ? ChatStrings.tooLong : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  IconButton.filled(
                    tooltip: ChatStrings.send,
                    onPressed: text.isEmpty || tooLong ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              );
              final note = _aiNote;
              if (note == null || text.isEmpty) return row;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                    child: IconText(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.accent,
                      iconSize: 14,
                      text: note,
                      maxLines: 2,
                      style: AppTextStyles.caption,
                    ),
                  ),
                  row,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
