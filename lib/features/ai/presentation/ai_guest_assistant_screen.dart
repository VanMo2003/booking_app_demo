import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../notification/presentation/app_link_navigator.dart';
import '../../notification/services/app_link.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiGuestAssistantCubit extends LoadCubit<GuestAnswer> {
  AiGuestAssistantCubit(this._ask);

  final AskGuestAssistant _ask;
  String _query = '';

  Future<void> ask(String query) {
    _query = query.trim();
    if (_query.isEmpty) return Future.value();
    return load();
  }

  @override
  Future<void> load() => guard(() => _ask(_query));
}

/// Trợ lý riêng của khách: hỏi về chính các đơn của mình bằng câu bình thường. Trợ lý chỉ đọc đơn phòng,
/// đơn tour, mã giảm giá và sở thích của khách đang đăng nhập; không đặt, không huỷ, không thanh toán hộ.
@RoutePage()
class AiGuestAssistantScreen extends StatelessWidget {
  const AiGuestAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiGuestAssistantCubit>(),
      child: const _AssistantView(),
    );
  }
}

class _AssistantView extends StatefulWidget {
  const _AssistantView();

  @override
  State<_AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<_AssistantView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? text]) {
    if (text != null) _query.text = text;
    FocusScope.of(context).unfocus();
    context.read<AiGuestAssistantCubit>().ask(_query.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AiStrings.guestTitle,
      body: BlocBuilder<AiGuestAssistantCubit, LoadState<GuestAnswer>>(
        builder: (context, state) {
          final busy = state.isLoading;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(AiStrings.guestIntro, style: AppTextStyles.bodySmall),
              const Gap(AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                    ),
                    const Gap(AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _query,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 300,
                        textInputAction: TextInputAction.search,
                        onSubmitted: busy ? null : (_) => _submit(),
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: AiStrings.guestHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          counterText: '',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: AiStrings.askAction,
                      onPressed: busy ? null : _submit,
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              ...switch (state.status) {
                ViewStatus.initial => [_GuestExamples(onPick: _submit)],
                ViewStatus.loading when !state.hasData => const [AppLoadingView()],
                ViewStatus.failure => [
                    AppFailureView.fromState(state, onRetry: () => _submit(), compact: true),
                    const Gap(AppSpacing.md),
                    _GuestExamples(onPick: _submit),
                  ],
                _ => [
                    _GuestAnswerCard(answer: state.data!),
                    const Gap(AppSpacing.md),
                    _GuestExamples(onPick: _submit),
                  ],
              },
            ],
          );
        },
      ),
    );
  }
}

class _GuestExamples extends StatelessWidget {
  const _GuestExamples({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.examplesTitle),
        for (final example in AiStrings.guestExamples) ...[
          AppCard(
            onTap: () => onPick(example),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: IconText(
              icon: Icons.north_west_rounded,
              iconColor: AppColors.primary,
              text: example,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

class _GuestAnswerCard extends StatelessWidget {
  const _GuestAnswerCard({required this.answer});

  final GuestAnswer answer;

  Future<void> _open(BuildContext context, String target) async {
    final link = AppLink.parse('${AppLink.scheme}://$target');
    if (link == null) return;
    await AppLinkNavigator(context.router, context.read<SessionCubit>()).open(link);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final note in answer.notes) ...[
          NoticeBanner(text: note, tone: StatusTone.warning),
          const Gap(AppSpacing.xs),
        ],
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                  const Gap(AppSpacing.xs),
                  Expanded(child: Text(AiStrings.guestFrom, style: AppTextStyles.caption)),
                ],
              ),
              if (answer.answer != null) ...[
                const Gap(AppSpacing.xs),
                Text(answer.answer!, style: AppTextStyles.bodyMedium),
              ],
              if (answer.links.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final link in answer.links)
                      OutlinedButton.icon(
                        onPressed: () => _open(context, link.target),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(link.label),
                      ),
                  ],
                ),
              ],
              if (answer.suggestions.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                const GroupLabel(AiStrings.guestNext),
                for (final line in answer.suggestions)
                  IconText(
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: AppColors.accent,
                    text: line,
                    maxLines: 3,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
              const Gap(AppSpacing.xs),
              Text(AiStrings.guestNote, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
