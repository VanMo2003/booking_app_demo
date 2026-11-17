import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../chat/presentation/chat_entry.dart';
import '../../notification/presentation/app_link_navigator.dart';
import '../../notification/services/app_link.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

/// "Hỏi nhanh về cơ sở này": khách đang xem trang cơ sở gõ một câu và nhận câu trả lời dựng từ đúng
/// những gì cơ sở đã công bố. Không cần đăng nhập và không mở hội thoại — hồ sơ cơ sở không có thông
/// tin thì AI nói thẳng là chưa có, và bảng mời khách nhắn cho cơ sở thay vì hiện một câu đoán.
Future<void> showHotelAsk(BuildContext context, int hotelId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _HotelAskSheet(hotelId: hotelId),
    ),
  );
}

class _HotelAskSheet extends StatefulWidget {
  const _HotelAskSheet({required this.hotelId});

  final int hotelId;

  @override
  State<_HotelAskSheet> createState() => _HotelAskSheetState();
}

class _HotelAskSheetState extends State<_HotelAskSheet> {
  final _question = TextEditingController();
  HotelAnswer? _answer;
  String? _error;
  bool _asking = false;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _question.text.trim();
    if (question.isEmpty) {
      setState(() => _error = AiStrings.askHotelEmpty);
      return;
    }
    setState(() {
      _asking = true;
      _error = null;
    });
    final result = await runAction(() => getIt<AskAboutHotel>()(widget.hotelId, question));
    if (!mounted) return;
    setState(() {
      _asking = false;
      _answer = result.value;
      _error = result.error;
    });
  }

  Future<void> _open(String target) async {
    final link = AppLink.parse('${AppLink.scheme}://$target');
    if (link == null) return;
    await AppLinkNavigator(context.router, context.read<SessionCubit>()).open(link);
  }

  @override
  Widget build(BuildContext context) {
    final answer = _answer;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.accent),
                const Gap(AppSpacing.xs),
                Expanded(child: Text(AiStrings.askHotelTitle, style: AppTextStyles.subtitle)),
              ],
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _question,
              hint: AiStrings.askHotelHint,
              maxLines: 2,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _ask(),
            ),
            const Gap(AppSpacing.sm),
            AppButton(
              label: AiStrings.askHotelSend,
              icon: Icons.send_rounded,
              size: AppButtonSize.small,
              loading: _asking,
              expand: true,
              onPressed: _ask,
            ),
            if (_error != null) ...[
              const Gap(AppSpacing.sm),
              NoticeBanner(text: _error!, tone: StatusTone.danger),
            ],
            if (answer != null) ...[
              const Gap(AppSpacing.md),
              for (final note in answer.notes) ...[
                NoticeBanner(text: note, tone: StatusTone.warning),
                const Gap(AppSpacing.xs),
              ],
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AiStrings.askHotelFrom, style: AppTextStyles.caption),
                    const Gap(AppSpacing.xs),
                    if (answer.answer != null) Text(answer.answer!, style: AppTextStyles.bodyMedium),
                    if (!answer.answered) ...[
                      const Gap(AppSpacing.sm),
                      // Hồ sơ không có thông tin: đưa khách sang chỗ hỏi được người thật.
                      AppButton.text(
                        label: AiStrings.askHotelChat,
                        size: AppButtonSize.small,
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.openHotelChat(widget.hotelId);
                        },
                      ),
                    ],
                    for (final link in answer.links) ...[
                      const Gap(4),
                      AppButton.text(
                        label: link.label,
                        size: AppButtonSize.small,
                        icon: Icons.open_in_new_rounded,
                        onPressed: () => _open(link.target),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
