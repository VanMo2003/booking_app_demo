import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/auth_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';

/// Khôi phục phiên rồi chuyển tới trang nhà theo vai trò.
@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    setState(() => _error = null);
    final startedAt = DateTime.now();
    final session = await context.read<SessionCubit>().restore();
    final elapsed = DateTime.now().difference(startedAt);
    const minimum = Duration(milliseconds: 700);
    if (elapsed < minimum) await Future<void>.delayed(minimum - elapsed);
    if (!mounted) return;
    final error = await SessionNavigator.goHome(context, session);
    if (error != null && mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const BrandMark(size: 80, onDark: true),
                const Gap(AppSpacing.lg),
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.display.colored(AppColors.onPrimary),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.colored(
                    AppColors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(flex: 2),
                if (_error == null)
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.onPrimary.withValues(alpha: 0.9),
                    ),
                  )
                else ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.colored(AppColors.onPrimary),
                  ),
                  const Gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton.tonal(
                        label: AppStrings.retry,
                        size: AppButtonSize.medium,
                        onPressed: _start,
                      ),
                      const Gap(AppSpacing.sm),
                      AppButton.text(
                        label: AppStrings.logout,
                        onPressed: () => SessionNavigator.logout(context),
                      ),
                    ],
                  ),
                ],
                const Gap(AppSpacing.xxl),
                Text(
                  AuthStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.colored(
                    AppColors.onPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
