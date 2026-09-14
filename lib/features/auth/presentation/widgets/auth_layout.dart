import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';

/// Khung chung cho Đăng nhập / Đăng ký / Hoàn tất hồ sơ: đầu trang xanh ngọc,
/// thẻ form nổi chồng lên.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            GradientHeader(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 64),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 44,
                        child: showBack
                            ? CircleIconButton(
                                icon: Icons.arrow_back_rounded,
                                color: AppColors.onPrimary,
                                background: AppColors.onPrimary.withValues(alpha: 0.16),
                                onPressed: () => context.router.maybePop(),
                              )
                            : null,
                      ),
                      const Gap(AppSpacing.xs),
                      const BrandMark(size: 52, onDark: true),
                      const Gap(AppSpacing.lg),
                      Text(
                        title,
                        style: AppTextStyles.display.colored(AppColors.onPrimary),
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.body.colored(
                          AppColors.onPrimary.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: AppSpacing.pageHorizontal,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        AppCard(
                          elevated: true,
                          radius: AppRadius.lg,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: child,
                        ),
                        if (footer != null) ...[
                          const Gap(AppSpacing.md),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
