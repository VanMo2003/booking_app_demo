import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/config/app_config.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';

/// Tab Thêm của chủ khách sạn.
@RoutePage()
class OwnerMoreScreen extends StatelessWidget {
  const OwnerMoreScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state.session;
    final chain = session?.hotelChain;
    if (session == null || chain == null) return const SizedBox.shrink();
    final router = context.rootRouter;
    return AppPage(
      title: ManagementStrings.tabMore,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          AppCard(
            child: Row(
              children: [
                AppAvatar(
                  name: chain.name,
                  imagePath: chain.pathImage,
                  size: 52,
                  tone: StatusTone.warning,
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chain.name,
                        style: AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('@${session.username}', style: AppTextStyles.caption),
                      const Gap(6),
                      StatusBadge.role(session.role, dense: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          MenuGroup(
            title: ManagementStrings.chainGroup,
            children: [
              MenuTile(
                icon: Icons.manage_accounts_outlined,
                title: ManagementStrings.managersTitle,
                onTap: () => router.push(ManagersRoute(chainId: chain.id)),
              ),
              MenuTile(
                icon: Icons.apartment_rounded,
                title: ManagementStrings.chainInfoTitle,
                subtitle: chain.name,
                onTap: () => router.push(ChainInfoRoute(chainId: chain.id)),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          MenuGroup(
            title: AppStrings.aboutApp,
            children: [
              const MenuTile(
                icon: Icons.info_outline_rounded,
                title: AppStrings.appName,
                subtitle: AppStrings.version,
              ),
              MenuTile(
                icon: Icons.dns_outlined,
                title: AppStrings.apiAddress,
                subtitle: AppConfig.baseUrl,
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
          AppButton(
            variant: AppButtonVariant.dangerOutline,
            label: AppStrings.logout,
            icon: Icons.logout_rounded,
            expand: true,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
