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
import '../../../core/utils/formatters.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiDailyBriefCubit extends LoadCubit<DailyBrief> {
  AiDailyBriefCubit(this._brief);

  final GetDailyBrief _brief;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _brief(_hotelId));
}

/// Bản tin đầu ngày của một cơ sở: những gì đang chờ xử lý hôm nay. Mọi con số do máy chủ đếm trên
/// dữ liệu thật; AI chỉ xếp thứ tự và viết mỗi việc một câu. Màn này không sửa gì — quản lý đọc rồi
/// tự vào đúng trang để xử lý.
@RoutePage()
class AiDailyBriefScreen extends StatelessWidget {
  const AiDailyBriefScreen({super.key, required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiDailyBriefCubit>()..start(hotelId),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.briefTitle,
          subtitle: subtitle,
          actions: [
            IconButton(
              tooltip: AiStrings.pricingRefresh,
              onPressed: context.read<AiDailyBriefCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: BlocBuilder<AiDailyBriefCubit, LoadState<DailyBrief>>(
            builder: (context, state) => LoadStateView<DailyBrief>(
              state: state,
              onRetry: context.read<AiDailyBriefCubit>().load,
              builder: (context, brief) => ListView(
                padding: AppSpacing.page,
                children: [
                  _HeadCard(brief: brief),
                  for (final note in brief.notes) ...[
                    const Gap(AppSpacing.xs),
                    NoticeBanner(text: note, tone: StatusTone.warning),
                  ],
                  if (brief.tasks.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: AiStrings.briefTodo),
                    const Gap(AppSpacing.xs),
                    for (final task in brief.tasks) ...[
                      _TaskCard(task: task),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                  if (brief.live.isNotEmpty) ...[
                    const Gap(AppSpacing.md),
                    const SectionHeader(title: AiStrings.briefLive),
                    const Gap(AppSpacing.xs),
                    for (final signal in brief.live) ...[
                      _SignalCard(signal: signal),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                  if (brief.calm.isNotEmpty) ...[
                    const Gap(AppSpacing.md),
                    const SectionHeader(title: AiStrings.briefCalm),
                    const Gap(AppSpacing.xs),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        children: [
                          for (final signal in brief.calm)
                            InfoRow(label: signal.label, value: signal.value),
                        ],
                      ),
                    ),
                  ],
                  const Gap(AppSpacing.md),
                  Text(AiStrings.briefNote, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.brief});

  final DailyBrief brief;

  @override
  Widget build(BuildContext context) {
    final urgent = brief.urgentCount;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(Fmt.date(brief.date), style: AppTextStyles.bodyStrong)),
              if (urgent > 0)
                StatusBadge(
                  label: AiStrings.briefUrgentCount(urgent),
                  tone: StatusTone.danger,
                  dense: true,
                ),
            ],
          ),
          if (brief.headline != null) ...[
            const Gap(AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                const Gap(AppSpacing.xs),
                Expanded(child: Text(brief.headline!, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ],
          if (brief.live.isEmpty) ...[
            const Gap(AppSpacing.sm),
            Text(AiStrings.briefAllQuiet, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final BriefTask task;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (task.priority) {
      AuditPriority.high => (AiStrings.auditHigh, StatusTone.danger),
      AuditPriority.medium => (AiStrings.auditMedium, StatusTone.warning),
      AuditPriority.low => (AiStrings.auditLow, StatusTone.neutral),
    };
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(task.title, style: AppTextStyles.bodyStrong, maxLines: 2)),
              const Gap(AppSpacing.xs),
              StatusBadge(label: label, tone: tone, dense: true),
            ],
          ),
          if (task.why != null) ...[
            const Gap(4),
            Text(task.why!, style: AppTextStyles.bodySmall),
          ],
          const Gap(4),
          IconText(
            icon: Icons.play_arrow_rounded,
            iconColor: AppColors.primary,
            text: task.how,
            maxLines: 3,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final BriefSignal signal;

  @override
  Widget build(BuildContext context) {
    final urgent = signal.level == BriefLevel.urgent;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            urgent ? Icons.error_outline_rounded : Icons.visibility_outlined,
            size: 18,
            color: urgent ? AppColors.danger : AppColors.warning,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(signal.label, style: AppTextStyles.bodyMedium),
                if (signal.detail != null) Text(signal.detail!, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(signal.value, style: AppTextStyles.bodyStrong),
              StatusBadge(
                label: urgent ? AiStrings.briefUrgent : AiStrings.briefWatch,
                tone: urgent ? StatusTone.danger : StatusTone.warning,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
