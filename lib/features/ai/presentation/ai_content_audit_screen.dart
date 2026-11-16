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
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiContentAuditCubit extends LoadCubit<ContentAudit> {
  AiContentAuditCubit(this._audit);

  final GetContentAudit _audit;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _audit(_hotelId));
}

/// Trang bán phòng của cơ sở còn thiếu gì: các tiêu chí và điểm số do máy chủ đếm từ dữ liệu thật,
/// phần "nên làm trước" do AI diễn đạt. Không sửa gì — quản lý tự vào từng mục để bổ sung.
@RoutePage()
class AiContentAuditScreen extends StatelessWidget {
  const AiContentAuditScreen({super.key, required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiContentAuditCubit>()..start(hotelId),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.auditTitle,
          subtitle: subtitle,
          actions: [
            IconButton(
              tooltip: AiStrings.pricingRefresh,
              onPressed: context.read<AiContentAuditCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: BlocBuilder<AiContentAuditCubit, LoadState<ContentAudit>>(
            builder: (context, state) => LoadStateView<ContentAudit>(
              state: state,
              onRetry: context.read<AiContentAuditCubit>().load,
              builder: (context, audit) => ListView(
                padding: AppSpacing.page,
                children: [
                  _ScoreCard(audit: audit),
                  for (final note in audit.notes) ...[
                    const Gap(AppSpacing.xs),
                    NoticeBanner(text: note, tone: StatusTone.warning),
                  ],
                  if (audit.items.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    const SectionHeader(title: AiStrings.auditTodo),
                    const Gap(AppSpacing.xs),
                    for (final item in audit.items) ...[
                      _ItemCard(item: item),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                  const Gap(AppSpacing.md),
                  const SectionHeader(title: AiStrings.auditChecks),
                  const Gap(AppSpacing.xs),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      children: [
                        for (final check in audit.checks) _CheckRow(check: check),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Text(AiStrings.auditNote, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.audit});

  final ContentAudit audit;

  @override
  Widget build(BuildContext context) {
    final tone = audit.score >= 90
        ? AppColors.success
        : audit.score >= 60
            ? AppColors.warning
            : AppColors.danger;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${audit.score}', style: AppTextStyles.headline.colored(tone)),
              Text('/100', style: AppTextStyles.bodySmall),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  AiStrings.auditPassed(audit.passedCount, audit.checks.length),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: audit.score / 100,
              minHeight: 6,
              backgroundColor: AppColors.line,
              color: tone,
            ),
          ),
          if (audit.summary != null) ...[
            const Gap(AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
                const Gap(AppSpacing.xs),
                Expanded(child: Text(audit.summary!, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final AuditItem item;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (item.priority) {
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
              Expanded(child: Text(item.title, style: AppTextStyles.bodyStrong, maxLines: 2)),
              const Gap(AppSpacing.xs),
              StatusBadge(label: label, tone: tone, dense: true),
            ],
          ),
          if (item.why != null) ...[
            const Gap(4),
            Text(item.why!, style: AppTextStyles.bodySmall),
          ],
          const Gap(4),
          IconText(
            icon: Icons.build_outlined,
            iconColor: AppColors.primary,
            text: item.how,
            maxLines: 3,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final AuditCheck check;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: check.passed ? AppColors.success : AppColors.inkTertiary,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(check.label, style: AppTextStyles.bodyMedium),
                if (!check.passed && check.hint != null) Text(check.hint!, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (check.progress != null) ...[
            const Gap(AppSpacing.xs),
            Text(check.progress!, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}
