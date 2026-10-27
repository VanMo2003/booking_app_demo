import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/report_entities.dart';

/// "2026-10" → "10/2026".
String _monthLabel(String month) {
  final parts = month.split('-');
  return parts.length == 2 ? '${parts[1]}/${parts[0]}' : month;
}

/// Tháng này so với mục tiêu doanh thu, trên màn Tổng quan. Quản lý sửa mục
/// tiêu của cơ sở mình qua [onEdit]; chủ chuỗi thấy tổng chuỗi và sửa từng cơ
/// sở trong [branches] qua [onEditBranch].
class TargetProgressCard extends StatelessWidget {
  const TargetProgressCard({
    super.key,
    required this.progress,
    this.onEdit,
    this.branches = const [],
    this.onEditBranch,
  });

  final TargetProgress progress;
  final VoidCallback? onEdit;
  final List<TargetProgress> branches;
  final ValueChanged<TargetProgress>? onEditBranch;

  bool get _isChain => onEditBranch != null;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionHeader(
                  title: ReportStrings.targetTitle(_monthLabel(progress.month)),
                  subtitle: ReportStrings.targetDay(progress.daysElapsed, progress.daysInMonth),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: progress.hasTarget ? ReportStrings.editTarget : ReportStrings.setTarget,
                  onPressed: onEdit,
                  icon: const Icon(Icons.flag_outlined),
                ),
            ],
          ),
          const Gap(AppSpacing.sm),
          if (progress.hasTarget)
            _Progress(progress: progress)
          else ...[
            Text(
              _isChain ? ReportStrings.noChainTarget : ReportStrings.noTarget,
              style: AppTextStyles.bodySmall,
            ),
            if (onEdit != null) ...[
              const Gap(AppSpacing.sm),
              AppButton.tonal(
                label: ReportStrings.setTarget,
                icon: Icons.flag_outlined,
                size: AppButtonSize.medium,
                onPressed: onEdit,
              ),
            ],
          ],
          if (_isChain && progress.hasTarget) ...[
            const Gap(AppSpacing.xs),
            Text(ReportStrings.chainTargetNote, style: AppTextStyles.caption),
          ],
          if (branches.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            const Divider(height: 1, color: AppColors.lineSoft),
            for (final branch in branches)
              _BranchTargetRow(branch: branch, onEdit: () => onEditBranch?.call(branch)),
          ],
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress});

  final TargetProgress progress;

  @override
  Widget build(BuildContext context) {
    final target = progress.target!;
    final projectedRate = progress.projectedRate ?? 0;
    final onTrack = projectedRate >= 100;
    final colors = (onTrack ? StatusTone.success : StatusTone.warning).colors;
    final shortfall = target - progress.projectedRevenue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                ReportStrings.targetAchieved(Fmt.money(progress.revenue), Fmt.money(target)),
                style: AppTextStyles.tabular.weight(FontWeight.w600),
              ),
            ),
            Text(
              Fmt.percent(progress.achievedRate),
              style: AppTextStyles.subtitle.colored(AppColors.primaryDark),
            ),
          ],
        ),
        const Gap(AppSpacing.xs),
        TargetBar(achieved: (progress.achievedRate ?? 0) / 100, projected: projectedRate / 100),
        const Gap(AppSpacing.xs),
        Row(
          children: [
            Icon(
              onTrack ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
              size: 16,
              color: colors.foreground,
            ),
            const Gap(4),
            Expanded(
              child: Text(
                [
                  ReportStrings.targetProjected(Fmt.money(progress.projectedRevenue), Fmt.percent(projectedRate)),
                  if (!onTrack && shortfall > 0) ReportStrings.targetShortfall(Fmt.money(shortfall)),
                ].join(' · '),
                style: AppTextStyles.caption.colored(colors.foreground),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Thanh tiến độ: phần đậm là đã đạt, phần nhạt phía sau là dự kiến cả tháng.
class TargetBar extends StatelessWidget {
  const TargetBar({super.key, required this.achieved, required this.projected, this.height = 10});

  final double achieved;
  final double projected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.smAll,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.surfaceSunk),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: projected.clamp(0, 1).toDouble(),
              child: const ColoredBox(color: AppColors.primarySoft),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: achieved.clamp(0, 1).toDouble(),
              child: const ColoredBox(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchTargetRow extends StatelessWidget {
  const _BranchTargetRow({required this.branch, required this.onEdit});

  final TargetProgress branch;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.hotelName ?? '',
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        branch.hasTarget ? Fmt.percent(branch.achievedRate) : ReportStrings.noTargetShort,
                        style: AppTextStyles.captionStrong,
                      ),
                    ],
                  ),
                  const Gap(6),
                  TargetBar(
                    height: 6,
                    achieved: (branch.achievedRate ?? 0) / 100,
                    projected: (branch.projectedRate ?? 0) / 100,
                  ),
                  const Gap(4),
                  Text(
                    branch.hasTarget
                        ? ReportStrings.targetAchieved(
                            Fmt.moneyCompact(branch.revenue),
                            Fmt.moneyCompact(branch.target),
                          )
                        : Fmt.money(branch.revenue),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.xs),
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.inkTertiary),
          ],
        ),
      ),
    );
  }
}

/// Hộp thoại nhập mục tiêu. Trả số tiền mới, 0 khi bỏ mục tiêu, `null` khi huỷ.
Future<double?> showTargetDialog(
  BuildContext context, {
  required String branchName,
  required String month,
  double? current,
}) {
  final controller = TextEditingController(text: ThousandsInputFormatter.format(current));
  final formKey = GlobalKey<FormState>();
  return showDialog<double>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(ReportStrings.targetTitle(_monthLabel(month))),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branchName, style: AppTextStyles.bodySmall),
            const Gap(AppSpacing.sm),
            AppMoneyField(
              controller: controller,
              label: ReportStrings.targetAmount,
              validator: Validators.money,
            ),
          ],
        ),
      ),
      actions: [
        if (current != null)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(0),
            child: const Text(ReportStrings.removeTarget),
          ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() != true) return;
            Navigator.of(dialogContext).pop(Validators.parseMoney(controller.text));
          },
          child: const Text(AppStrings.save),
        ),
      ],
    ),
  );
}
