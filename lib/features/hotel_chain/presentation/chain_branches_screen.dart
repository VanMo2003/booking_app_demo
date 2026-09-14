import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../hotel/domain/entities/hotel.dart';
import '../../hotel/domain/usecases/hotel_usecases.dart';
import '../domain/entities/hotel_chain.dart';
import '../domain/usecases/hotel_chain_usecases.dart';
import 'chain_cubits.dart';

enum _BranchMenu { info, delete }

/// Tab Cơ sở của chủ khách sạn: mở cơ sở, bật/tắt nhận khách, vào quản lý.
@RoutePage()
class ChainBranchesScreen extends StatefulWidget {
  const ChainBranchesScreen({super.key});

  @override
  State<ChainBranchesScreen> createState() => _ChainBranchesScreenState();
}

class _ChainBranchesScreenState extends State<ChainBranchesScreen> {
  HotelChainDetail? _managersFor;
  Future<Map<String, String>>? _managerNames;

  /// Tên đăng nhập của quản lý theo accountId — BE chỉ trả id trên cơ sở.
  Future<Map<String, String>> _loadManagerNames(HotelChainDetail detail) async {
    final ownerUsername = context.read<SessionCubit>().session?.username ?? '';
    try {
      final managers = await getIt<GetChainManagers>()(detail, ownerUsername: ownerUsername);
      return {for (final manager in managers) manager.account.id: manager.account.username};
    } catch (_) {
      return const {};
    }
  }

  Future<void> _reload() => context.read<ChainCubit>().load();

  Future<void> _openForm(int chainId) async {
    final saved = await context.rootRouter.push<bool>(BranchFormRoute(chainId: chainId));
    if (saved == true && mounted) await _reload();
  }

  Future<void> _openInfo(Hotel hotel) async {
    final saved = await context.rootRouter.push<bool>(BranchInfoRoute(hotelId: hotel.id));
    if (saved == true && mounted) await _reload();
  }

  Future<void> _toggleActive(Hotel hotel) async {
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<SetBranchActive>()(hotel.id, active: !hotel.active)),
      successMessage: hotel.active ? ManagementStrings.deactivated : ManagementStrings.activated,
    );
    if (result.isSuccess && mounted) await _reload();
  }

  Future<void> _delete(Hotel hotel) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: '${hotel.name}\n\n${ManagementStrings.deleteBranchMessage}',
      confirmLabel: AppStrings.delete,
      destructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (!confirmed || !mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteBranch>()(hotel.id)),
      successMessage: AppStrings.deleted,
    );
    if (result.isSuccess && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChainCubit, LoadState<HotelChainDetail>>(
      builder: (context, state) {
        final detail = state.data;
        if (detail != null && !identical(detail, _managersFor)) {
          _managersFor = detail;
          _managerNames = _loadManagerNames(detail);
        }
        return AppPage(
          title: ManagementStrings.branchesTitle,
          subtitle: detail == null
              ? null
              : ManagementStrings.activeBranches(detail.activeCount, detail.hotels.length),
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          floatingActionButton: detail == null || detail.hotels.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(detail.chain.id),
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text(ManagementStrings.openBranch),
                ),
          body: LoadStateView<HotelChainDetail>(
            state: state,
            onRetry: _reload,
            isEmpty: (data) => data.hotels.isEmpty,
            empty: AppEmptyView(
              icon: Icons.apartment_rounded,
              title: ManagementStrings.branchesEmpty,
              message: ManagementStrings.branchesEmptyHint,
              addLabel: ManagementStrings.openBranch,
              onAdd: detail == null ? null : () => _openForm(detail.chain.id),
            ),
            builder: (context, data) => FutureBuilder<Map<String, String>>(
              future: _managerNames,
              builder: (context, snapshot) {
                final names = snapshot.data ?? const <String, String>{};
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      AppSpacing.bottomBarClearance,
                    ),
                    itemCount: data.hotels.length,
                    separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final hotel = data.hotels[index];
                      return _BranchCard(
                        hotel: hotel,
                        managerName: names[hotel.accountId],
                        onOpen: () =>
                            context.rootRouter.push(WorkspaceShellRoute(hotelId: hotel.id)),
                        onToggle: () => _toggleActive(hotel),
                        onMenu: (action) {
                          switch (action) {
                            case _BranchMenu.info:
                              _openInfo(hotel);
                            case _BranchMenu.delete:
                              _delete(hotel);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.hotel,
    required this.onOpen,
    required this.onToggle,
    required this.onMenu,
    this.managerName,
  });

  final Hotel hotel;
  final String? managerName;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final ValueChanged<_BranchMenu> onMenu;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    path: hotel.pathImage,
                    width: 72,
                    height: 72,
                    borderRadius: AppRadius.smAll,
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: AppTextStyles.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        IconText(icon: Icons.location_on_outlined, text: hotel.address),
                        const Gap(6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            StatusBadge(
                              dense: true,
                              label: hotel.active
                                  ? WorkspaceStrings.branchActive
                                  : WorkspaceStrings.branchInactive,
                              tone: hotel.active ? StatusTone.success : StatusTone.neutral,
                            ),
                            if (managerName != null)
                              SoftTag(
                                label: managerName!,
                                icon: Icons.person_outline_rounded,
                                tone: StatusTone.info,
                              ),
                            if (hotel.category.isNotEmpty) SoftTag(label: hotel.category),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_BranchMenu>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkTertiary),
                    onSelected: onMenu,
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: _BranchMenu.info,
                        child: Text(WorkspaceStrings.menuBranchInfo),
                      ),
                      PopupMenuItem(
                        value: _BranchMenu.delete,
                        child: Text(
                          AppStrings.delete,
                          style: AppTextStyles.body.colored(AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: AppButton.tonal(
                    label: ManagementStrings.openWorkspace,
                    icon: Icons.login_rounded,
                    size: AppButtonSize.small,
                    onPressed: onOpen,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    variant: hotel.active
                        ? AppButtonVariant.dangerOutline
                        : AppButtonVariant.secondary,
                    label: hotel.active
                        ? ManagementStrings.deactivate
                        : ManagementStrings.activate,
                    icon: hotel.active
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: AppButtonSize.small,
                    onPressed: onToggle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
