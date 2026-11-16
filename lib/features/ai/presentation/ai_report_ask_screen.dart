import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiReportAskCubit extends LoadCubit<AiReportAnswer> {
  AiReportAskCubit(this._ask);

  final AskReportsWithAi _ask;
  String _query = '';
  int? _hotelId;
  int? _hotelChainId;

  void scope({int? hotelId, int? hotelChainId}) {
    _hotelId = hotelId;
    _hotelChainId = hotelChainId;
  }

  Future<void> ask(String query) {
    _query = query.trim();
    if (_query.isEmpty) return Future.value();
    return load();
  }

  @override
  Future<void> load() => guard(() => _ask(_query, hotelId: _hotelId, hotelChainId: _hotelChainId));
}

/// Hỏi về số liệu bằng câu bình thường: "doanh thu tháng này so với tháng trước thế nào?". Câu trả lời
/// được viết từ chính số liệu báo cáo của cơ sở hoặc chuỗi, kèm kỳ số liệu để đối chiếu với tab báo cáo.
@RoutePage()
class AiReportAskScreen extends StatelessWidget {
  const AiReportAskScreen({super.key, this.hotelId, this.hotelChainId, this.subtitle});

  final int? hotelId;
  final int? hotelChainId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiReportAskCubit>()..scope(hotelId: hotelId, hotelChainId: hotelChainId),
      child: _AskView(subtitle: subtitle),
    );
  }
}

class _AskView extends StatefulWidget {
  const _AskView({this.subtitle});

  final String? subtitle;

  @override
  State<_AskView> createState() => _AskViewState();
}

class _AskViewState extends State<_AskView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? text]) {
    if (text != null) _query.text = text;
    FocusScope.of(context).unfocus();
    context.read<AiReportAskCubit>().ask(_query.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AiStrings.askTitle,
      subtitle: widget.subtitle,
      body: BlocBuilder<AiReportAskCubit, LoadState<AiReportAnswer>>(
        builder: (context, state) {
          final busy = state.isLoading;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(AiStrings.askIntro, style: AppTextStyles.bodySmall),
              const Gap(AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Icon(Icons.query_stats_rounded, color: AppColors.primary, size: 20),
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
                          hintText: AiStrings.askHint,
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
                ViewStatus.initial => [_AskExamples(onPick: _submit)],
                ViewStatus.loading when !state.hasData => const [AppLoadingView()],
                ViewStatus.failure => [
                    AppFailureView.fromState(state, onRetry: () => _submit(), compact: true),
                    const Gap(AppSpacing.md),
                    _AskExamples(onPick: _submit),
                  ],
                _ => [_Answer(answer: state.data!), const Gap(AppSpacing.md), _AskExamples(onPick: _submit)],
              },
            ],
          );
        },
      ),
    );
  }
}

class _AskExamples extends StatelessWidget {
  const _AskExamples({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.examplesTitle),
        for (final example in AiStrings.askExamples) ...[
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

class _Answer extends StatelessWidget {
  const _Answer({required this.answer});

  final AiReportAnswer answer;

  String get _period => answer.from == null || answer.to == null
      ? ''
      : '${Fmt.date(answer.from)} – ${Fmt.date(answer.to)}';

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
                  Expanded(
                    child: Text(
                      _period.isEmpty ? AiStrings.askPeriod : '${AiStrings.askPeriod}: $_period',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  IconButton(
                    tooltip: AiStrings.copyAnswer,
                    visualDensity: VisualDensity.compact,
                    onPressed: answer.answer == null
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: answer.answer!));
                            if (context.mounted) AppToast.success(context, AiStrings.answerCopied);
                          },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
                ],
              ),
              if (answer.answer != null) Text(answer.answer!, style: AppTextStyles.bodyMedium),
              if (answer.highlights.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                const GroupLabel(AiStrings.askHighlights),
                for (final line in answer.highlights)
                  IconText(
                    icon: Icons.insights_rounded,
                    iconColor: AppColors.primary,
                    text: line,
                    maxLines: 3,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
              if (answer.suggestions.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                const GroupLabel(AiStrings.askSuggestions),
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
              Text(AiStrings.askNote, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
