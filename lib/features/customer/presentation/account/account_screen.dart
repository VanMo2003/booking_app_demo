import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../auth/domain/entities/session.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../auth/presentation/session/session_navigator.dart';

/// Tab Tài khoản của khách.
@RoutePage()
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final session = state.session;
        final customer = session?.customer;
        final tabs = AutoTabsRouter.of(context);
        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _AccountHeader(session: session),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (customer != null) ...[
                      MenuGroup(
                        title: ExploreStrings.groupProfile,
                        children: [
                          MenuTile(
                            icon: Icons.person_outline_rounded,
                            title: ExploreStrings.editProfile,
                            subtitle: '${customer.fullName} · ${customer.phoneNumber}',
                            onTap: () => context.rootRouter.push(ProfileEditRoute(customer: customer)),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                    ],
                    if (session?.needsCustomerProfile ?? false) ...[
                      MenuGroup(
                        title: ExploreStrings.groupProfile,
                        children: [
                          MenuTile(
                            icon: Icons.badge_outlined,
                            title: AuthStrings.setupTitle,
                            subtitle: AuthStrings.setupCreateSubtitle,
                            onTap: () => context.rootRouter.push<bool>(ProfileSetupRoute(returnResult: true)),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                    ],
                    if (session != null) ...[
                      MenuGroup(
                        title: ExploreStrings.groupBooking,
                        children: [
                          MenuTile(
                            icon: Icons.receipt_long_outlined,
                            title: ExploreStrings.tabBookings,
                            onTap: () => tabs.setActiveIndex(1),
                          ),
                          MenuTile(
                            icon: Icons.favorite_border_rounded,
                            title: ExploreStrings.tabFavorites,
                            onTap: () => tabs.setActiveIndex(2),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                    ],
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
                    if (session != null) ...[
                      const Gap(AppSpacing.xl),
                      AppButton(
                        variant: AppButtonVariant.dangerOutline,
                        label: AppStrings.logout,
                        icon: Icons.logout_rounded,
                        expand: true,
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.session});

  final Session? session;

  @override
  Widget build(BuildContext context) {
    final current = session;
    final onDarkMuted = AppColors.onPrimary.withValues(alpha: 0.82);
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: current == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 52, onDark: true),
                const Gap(AppSpacing.md),
                Text(ExploreStrings.guestTitle, style: AppTextStyles.title.colored(AppColors.onPrimary)),
                const Gap(4),
                Text(ExploreStrings.guestSubtitle, style: AppTextStyles.body.colored(onDarkMuted)),
                const Gap(AppSpacing.md),
                Row(
                  children: [
                    AppButton.tonal(
                      label: AppStrings.login,
                      size: AppButtonSize.medium,
                      onPressed: () => context.rootRouter.push<bool>(LoginRoute(returnResult: true)),
                    ),
                    const Gap(AppSpacing.sm),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.onPrimary),
                      onPressed: () => context.rootRouter.push<bool>(RegisterRoute(returnResult: true)),
                      child: const Text(AppStrings.register),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.5)),
                  ),
                  child: AppAvatar(
                    name: current.displayName,
                    imagePath: current.customer?.pathImage,
                    size: 60,
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.displayName,
                        style: AppTextStyles.title.colored(AppColors.onPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('@${current.username}', style: AppTextStyles.bodySmall.colored(onDarkMuted)),
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          current.role.label,
                          style: AppTextStyles.captionStrong.colored(AppColors.onPrimary),
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
