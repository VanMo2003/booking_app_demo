import 'package:flutter/material.dart';

import '../bloc/load_state.dart';
import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/app_strings.dart';
import '../text/error_strings.dart';
import 'app_button.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message!,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.danger,
      iconBackground: AppColors.dangerSoft,
      title: AppStrings.errorTitle,
      message: message,
      action: onRetry == null
          ? null
          : AppButton.secondary(
              label: AppStrings.retry,
              icon: Icons.refresh_rounded,
              size: AppButtonSize.medium,
              onPressed: onRetry,
            ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: AppColors.primary,
      iconBackground: AppColors.primarySoft,
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Hiện ở các tab cần tài khoản khi người dùng chưa đăng nhập.
class LoginPromptView extends StatelessWidget {
  const LoginPromptView({
    super.key,
    required this.message,
    required this.onLogin,
    this.onRegister,
    this.icon = Icons.lock_outline_rounded,
    this.title = AppStrings.login,
  });

  final String title;
  final String message;
  final VoidCallback onLogin;
  final VoidCallback? onRegister;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: AppColors.primary,
      iconBackground: AppColors.primarySoft,
      title: title,
      message: message,
      action: Column(
        children: [
          AppButton(label: AppStrings.login, onPressed: onLogin, expand: true),
          if (onRegister != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppButton.text(label: AppStrings.register, onPressed: onRegister),
          ],
        ],
      ),
    );
  }
}

/// Dựng giao diện theo [LoadState]: đang tải → vòng xoay, lỗi → nút thử lại,
/// có dữ liệu → [builder]. Khi tải lại, dữ liệu cũ vẫn hiển thị.
class LoadStateView<T> extends StatelessWidget {
  const LoadStateView({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.empty,
    this.loading,
  });

  final LoadState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (data != null) {
      if (empty != null && isEmpty != null && isEmpty!(data)) return empty!;
      return builder(context, data);
    }
    if (state.isFailure) {
      return AppErrorView(
        message: state.error ?? ErrorStrings.unknown,
        onRetry: onRetry,
      );
    }
    return loading ?? const AppLoadingView();
  }
}
