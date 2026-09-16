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
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/partner_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../../notification/presentation/notification_bell.dart';
import '../domain/usecases/load_system_overview.dart';
import 'accounts_screen.dart';
import 'owner_approvals_screen.dart';

@injectable
class SystemOverviewCubit extends LoadCubit<SystemOverview> {
  SystemOverviewCubit(this._loadOverview);

  final LoadSystemOverview _loadOverview;

  @override
  Future<void> load() => guard(() => _loadOverview());
}

/// Vị trí các tab trong khung quản trị (khớp `AdminShellScreen`).
abstract final class _AdminTab {
  static const approvals = 1;
  static const accounts = 2;
  static const system = 4;
}

/// Tab Tổng quan của quản trị viên.
@RoutePage()
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SystemOverviewCubit>()..load(),
      child: const _AdminOverviewView(),
    );
  }
}

class _AdminOverviewView extends StatelessWidget {
  const _AdminOverviewView();

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmLabel: AppStrings.logout,
      destructive: true,
    );
    if (confirmed && context.mounted) await SessionNavigator.logout(context);
  }

  Future<void> _refresh(BuildContext context) async {
    final pending = context.read<PendingOwnersCubit>();
    await context.read<SystemOverviewCubit>().load();
    await pending.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final username = context.select((SessionCubit cubit) => cubit.state.session?.username);
    final onDarkMuted = AppColors.onPrimary.withValues(alpha: 0.82);
    return BlocBuilder<SystemOverviewCubit, LoadState<SystemOverview>>(
      builder: (context, state) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                GradientHeader(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 28),
                  child: Row(
                    children: [
                      const BrandMark(size: 48, onDark: true),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ManagementStrings.adminTitle,
                              style: AppTextStyles.title.colored(AppColors.onPrimary),
                            ),
                            if (username != null)
                              Text(
                                '@$username',
                                style: AppTextStyles.bodySmall.colored(onDarkMuted),
                              ),
                          ],
                        ),
                      ),
                      const NotificationBell(onDark: true),
                      IconButton(
                        tooltip: AppStrings.logout,
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout_rounded, color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
                if (state.isLoading && state.hasData) const LinearProgressIndicator(minHeight: 2),
                Padding(
                  padding: AppSpacing.page,
                  child: _content(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, LoadState<SystemOverview> state) {
    final data = state.data;
    if (data == null) {
      return state.isFailure
          ? AppFailureView.fromState(state, onRetry: () => _refresh(context))
          : const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxl),
              child: AppLoadingView(),
            );
    }
    final tabs = AutoTabsRouter.of(context);
    final pending = context.watch<PendingOwnersCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PendingOwnersCard(
          count: pending,
          onReview: () => tabs.setActiveIndex(_AdminTab.approvals),
        ),
        const Gap(AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: ManagementStrings.countAccounts,
                  value: Fmt.number(data.accounts),
                  icon: Icons.manage_accounts_outlined,
                  onTap: () => tabs.setActiveIndex(_AdminTab.accounts),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: ManagementStrings.countChains,
                  value: Fmt.number(data.chains),
                  icon: Icons.apartment_rounded,
                  tone: StatusTone.warning,
                  onTap: () => tabs.setActiveIndex(_AdminTab.system),
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: ManagementStrings.countBranches,
                  value: Fmt.number(data.branches),
                  icon: Icons.storefront_outlined,
                  tone: StatusTone.info,
                  onTap: () => tabs.setActiveIndex(_AdminTab.system),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: ManagementStrings.countCustomers,
                  value: Fmt.number(data.customers),
                  icon: Icons.groups_outlined,
                  tone: StatusTone.success,
                  onTap: () => tabs.setActiveIndex(_AdminTab.system),
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        StatCard(
          label: ManagementStrings.countEmployees,
          value: Fmt.number(data.employees),
          icon: Icons.badge_outlined,
          tone: StatusTone.neutral,
          onTap: () => tabs.setActiveIndex(_AdminTab.system),
        ),
        const Gap(AppSpacing.lg),
        SectionHeader(
          title: ManagementStrings.recentAccounts,
          actionLabel: AppStrings.seeAll,
          onAction: () => tabs.setActiveIndex(_AdminTab.accounts),
        ),
        const Gap(AppSpacing.sm),
        if (data.recentAccounts.isEmpty)
          Text(ManagementStrings.accountsEmpty, style: AppTextStyles.bodySmall)
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < data.recentAccounts.length; i++) ...[
                  if (i > 0) const Divider(),
                  AccountSummaryRow(account: data.recentAccounts[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Việc chính của quản trị viên: hồ sơ chủ khách sạn đang chờ duyệt.
class _PendingOwnersCard extends StatelessWidget {
  const _PendingOwnersCard({required this.count, required this.onReview});

  final int count;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final hasPending = count > 0;
    final colors = (hasPending ? StatusTone.warning : StatusTone.success).colors;
    return AppCard(
      onTap: onReview,
      borderColor: hasPending ? colors.foreground.withValues(alpha: 0.35) : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasPending ? Icons.fact_check_outlined : Icons.task_alt_rounded,
              color: colors.foreground,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPending ? PartnerStrings.pendingCount(count) : PartnerStrings.noPending,
                  style: AppTextStyles.bodyStrong,
                ),
                Text(
                  hasPending ? PartnerStrings.pendingCountHint : PartnerStrings.noPendingHint,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          if (hasPending)
            AppButton(
              label: PartnerStrings.reviewNow,
              size: AppButtonSize.small,
              onPressed: onReview,
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
        ],
      ),
    );
  }
}
