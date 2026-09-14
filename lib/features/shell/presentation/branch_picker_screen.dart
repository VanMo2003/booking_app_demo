import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../auth/domain/usecases/auth_usecases.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../../hotel/domain/entities/hotel.dart';

/// Quản lý phụ trách nhiều cơ sở (hoặc chưa được giao cơ sở nào) chọn nơi làm việc.
@RoutePage()
class BranchPickerScreen extends StatefulWidget {
  const BranchPickerScreen({super.key});

  @override
  State<BranchPickerScreen> createState() => _BranchPickerScreenState();
}

class _BranchPickerScreenState extends State<BranchPickerScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    final sessionCubit = context.read<SessionCubit>();
    final session = sessionCubit.session;
    if (session == null) return;
    setState(() => _refreshing = true);
    final result = await runAction(() => getIt<RefreshManagerBranches>()(session));
    if (!mounted) return;
    setState(() => _refreshing = false);
    if (result.isSuccess) {
      await sessionCubit.update(session.copyWith(hotels: result.value));
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotels = context.select((SessionCubit cubit) => cubit.state.session?.hotels) ??
        const <Hotel>[];
    return AppPage(
      title: WorkspaceStrings.pickerTitle,
      subtitle: WorkspaceStrings.pickerSubtitle,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          tooltip: AppStrings.refresh,
          onPressed: _refreshing ? null : _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          tooltip: AppStrings.logout,
          onPressed: () => SessionNavigator.logout(context),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: hotels.isEmpty
            ? ListView(
                children: [
                  const Gap(AppSpacing.xxl),
                  AppEmptyView(
                    icon: Icons.domain_disabled_outlined,
                    title: WorkspaceStrings.noBranchTitle,
                    message: WorkspaceStrings.noBranchMessage,
                    action: AppButton.secondary(
                      label: AppStrings.refresh,
                      icon: Icons.refresh_rounded,
                      size: AppButtonSize.medium,
                      loading: _refreshing,
                      onPressed: _refresh,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: AppSpacing.page,
                itemCount: hotels.length,
                separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return AppCard(
                    padding: const EdgeInsets.all(10),
                    onTap: () => context.router.push(WorkspaceShellRoute(hotelId: hotel.id)),
                    child: Row(
                      children: [
                        AppNetworkImage(
                          path: hotel.pathImage,
                          width: 76,
                          height: 76,
                          borderRadius: AppRadius.smAll,
                        ),
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hotel.name, style: AppTextStyles.bodyStrong),
                              const Gap(2),
                              IconText(icon: Icons.location_on_outlined, text: hotel.address),
                              const Gap(6),
                              StatusBadge(
                                dense: true,
                                label: hotel.active
                                    ? WorkspaceStrings.branchActive
                                    : WorkspaceStrings.branchInactive,
                                tone: hotel.active ? StatusTone.success : StatusTone.neutral,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
