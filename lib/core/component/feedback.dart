import 'package:flutter/material.dart';

import '../bloc/load_state.dart';
import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/app_strings.dart';
import 'app_button.dart';

/// Thông báo ngắn ở đáy màn hình.
abstract final class AppToast {
  /// Gắn vào `MaterialApp` để báo được cả khi không có `BuildContext` (phiên hết hạn).
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void success(BuildContext context, String message) =>
      _show(ScaffoldMessenger.maybeOf(context), message, Icons.check_circle_rounded, AppColors.successOnDark);

  static void error(BuildContext context, String message) =>
      _show(ScaffoldMessenger.maybeOf(context), message, Icons.error_rounded, AppColors.dangerOnDark);

  static void info(BuildContext context, String message) =>
      _show(ScaffoldMessenger.maybeOf(context), message, Icons.info_rounded, AppColors.infoOnDark);

  static void infoGlobal(String message) =>
      _show(messengerKey.currentState, message, Icons.info_rounded, AppColors.infoOnDark);

  static void _show(
    ScaffoldMessengerState? messenger,
    String message,
    IconData icon,
    Color iconColor,
  ) {
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

class AppChoice<T> {
  const AppChoice({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final bool destructive;
}

abstract final class AppDialogs {
  /// Hộp thoại xác nhận; trả `true` khi người dùng đồng ý.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    bool destructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: icon == null
            ? null
            : Icon(
                icon,
                color: destructive ? AppColors.danger : AppColors.primary,
                size: 32,
              ),
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: cancelLabel,
                  size: AppButtonSize.medium,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: confirmLabel,
                  size: AppButtonSize.medium,
                  variant: destructive
                      ? AppButtonVariant.danger
                      : AppButtonVariant.primary,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Bottom sheet có tiêu đề, tự đẩy lên khi bàn phím mở.
  static Future<T?> sheet<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => AppSheet(title: title, child: builder(sheetContext)),
    );
  }

  /// Danh sách lựa chọn dạng sheet.
  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<AppChoice<T>> choices,
  }) {
    return sheet<T>(
      context,
      title: title,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final choice in choices)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: choice.icon == null
                  ? null
                  : Icon(
                      choice.icon,
                      color: choice.destructive
                          ? AppColors.danger
                          : AppColors.inkSecondary,
                    ),
              title: Text(
                choice.label,
                style: AppTextStyles.bodyMedium.colored(
                  choice.destructive ? AppColors.danger : AppColors.ink,
                ),
              ),
              subtitle: choice.description == null
                  ? null
                  : Text(choice.description!),
              onTap: () => Navigator.of(sheetContext).pop(choice.value),
            ),
        ],
      ),
    );
  }
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.title)),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chạy thao tác ghi: phủ lớp chờ, báo lỗi/thành công bằng toast.
abstract final class AppAction {
  static Future<ActionResult<T>> run<T>(
    BuildContext context,
    Future<ActionResult<T>> Function() task, {
    String? successMessage,
    bool blocking = true,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (blocking) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.ink.withValues(alpha: 0.18),
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdAll,
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final result = await task();
    if (blocking && navigator.mounted) navigator.pop();
    if (context.mounted) {
      if (result.isSuccess) {
        if (successMessage != null) AppToast.success(context, successMessage);
      } else {
        AppToast.error(context, result.error!);
      }
    }
    return result;
  }
}
