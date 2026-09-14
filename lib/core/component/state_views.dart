import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/load_state.dart';
import '../di/injector.dart';
import '../network/app_exception.dart';
import '../network/network_status.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/app_strings.dart';
import '../text/error_strings.dart';
import '../text/state_strings.dart';
import 'app_button.dart';
import 'gap.dart';
import 'state_illustration.dart';

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

/// Khung chung của mọi màn trạng thái: ảnh minh hoạ, tiêu đề, mô tả và nút.
///
/// Mỗi phần ẩn/hiện được qua `show…`; phần nào không có nội dung (tiêu đề rỗng,
/// không có nút bấm) cũng tự ẩn.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    this.illustration = AppIllustrationType.empty,
    this.icon,
    this.image,
    this.imageAsset,
    this.title,
    this.description,
    this.buttonLabel,
    this.buttonIcon,
    this.onPressed,
    this.buttonVariant = AppButtonVariant.primary,
    this.buttonLoading = false,
    this.action,
    this.footer,
    this.showImage = true,
    this.showTitle = true,
    this.showDescription = true,
    this.showButton = true,
    this.compact = false,
  });

  /// Ảnh dựng sẵn, dùng khi không truyền [image] hoặc [imageAsset].
  final AppIllustrationType illustration;

  /// Biểu tượng chính trên ảnh dựng sẵn.
  final IconData? icon;

  /// Ảnh tuỳ chỉnh (`Image.asset`, `Image.network`, `SvgPicture`…).
  final Widget? image;

  /// Đường dẫn ảnh trong assets — nhớ khai báo thư mục ảnh trong pubspec.yaml.
  final String? imageAsset;

  final String? title;
  final String? description;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;
  final AppButtonVariant buttonVariant;
  final bool buttonLoading;

  /// Khối hành động tuỳ chỉnh, thay cho nút mặc định.
  final Widget? action;

  /// Dòng phụ dưới nút (ví dụ "Đang tải lại…").
  final Widget? footer;

  final bool showImage;
  final bool showTitle;
  final bool showDescription;
  final bool showButton;

  /// Bản gọn cho khối nằm giữa trang: ảnh nhỏ hơn, ít khoảng trắng.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final imageSize = compact ? 112.0 : 164.0;
    final hasTitle = showTitle && (title ?? '').isNotEmpty;
    final hasDescription = showDescription && (description ?? '').isNotEmpty;
    final Widget? button = !showButton
        ? null
        : action ??
            (buttonLabel == null || onPressed == null
                ? null
                : AppButton(
                    label: buttonLabel!,
                    icon: buttonIcon,
                    variant: buttonVariant,
                    size: AppButtonSize.medium,
                    loading: buttonLoading,
                    onPressed: onPressed,
                  ));
    final hasText = hasTitle || hasDescription;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: compact ? AppSpacing.md : AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showImage) ...[
                SizedBox.square(
                  dimension: imageSize,
                  child: image ??
                      (imageAsset != null
                          ? Image.asset(imageAsset!, fit: BoxFit.contain)
                          : AppIllustration(type: illustration, icon: icon)),
                ),
                if (hasText || button != null)
                  Gap(compact ? AppSpacing.sm : AppSpacing.md),
              ],
              if (hasTitle)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: compact ? AppTextStyles.subtitle : AppTextStyles.title,
                ),
              if (hasTitle && hasDescription) const Gap(AppSpacing.xs),
              if (hasDescription)
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
              if (button != null) ...[
                if (showImage || hasText) Gap(compact ? AppSpacing.md : AppSpacing.lg),
                button,
              ],
              if (footer != null) ...[
                const Gap(AppSpacing.sm),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lỗi hệ thống: BE không phản hồi, máy chủ lỗi hoặc lỗi không xác định.
/// Nút "Tải lại" chỉ hiện khi truyền [onRetry].
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.message,
    this.title = StateStrings.systemErrorTitle,
    this.onRetry,
    this.retryLabel = StateStrings.reload,
    this.illustration = AppIllustrationType.serverError,
    this.image,
    this.imageAsset,
    this.showImage = true,
    this.showTitle = true,
    this.showDescription = true,
    this.showButton = true,
    this.compact = false,
  });

  /// Mô tả lỗi; mặc định là thông báo lỗi hệ thống chung.
  final String? message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final AppIllustrationType illustration;
  final Widget? image;
  final String? imageAsset;
  final bool showImage;
  final bool showTitle;
  final bool showDescription;
  final bool showButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      illustration: illustration,
      image: image,
      imageAsset: imageAsset,
      title: title,
      description: message ?? StateStrings.systemErrorMessage,
      buttonLabel: retryLabel,
      buttonIcon: Icons.refresh_rounded,
      onPressed: onRetry,
      showImage: showImage,
      showTitle: showTitle,
      showDescription: showDescription,
      showButton: showButton,
      compact: compact,
    );
  }
}

/// Mất kết nối mạng. Có mạng trở lại thì tự gọi [onRetry] (khi [autoReload]).
class AppOfflineView extends StatefulWidget {
  const AppOfflineView({
    super.key,
    this.onRetry,
    this.title = StateStrings.offlineTitle,
    this.message = StateStrings.offlineMessage,
    this.retryLabel = StateStrings.reload,
    this.autoReload = true,
    this.image,
    this.imageAsset,
    this.showImage = true,
    this.showTitle = true,
    this.showDescription = true,
    this.showButton = true,
    this.compact = false,
  });

  final VoidCallback? onRetry;
  final String title;
  final String message;
  final String retryLabel;

  /// Tự tải lại khi thiết bị có mạng trở lại.
  final bool autoReload;
  final Widget? image;
  final String? imageAsset;
  final bool showImage;
  final bool showTitle;
  final bool showDescription;
  final bool showButton;
  final bool compact;

  @override
  State<AppOfflineView> createState() => _AppOfflineViewState();
}

class _AppOfflineViewState extends State<AppOfflineView> {
  StreamSubscription<bool>? _subscription;
  Timer? _resetTimer;
  bool _reconnecting = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoReload && widget.onRetry != null) {
      _subscription = getIt<NetworkStatus>().onChanged.listen(_handleNetwork);
    }
  }

  void _handleNetwork(bool online) {
    if (!online || !mounted || _reconnecting) return;
    setState(() => _reconnecting = true);
    widget.onRetry?.call();
    // Nếu màn không đổi trạng thái (tải lại vẫn lỗi), cho bấm lại sau ít giây.
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _reconnecting = false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      illustration: AppIllustrationType.offline,
      image: widget.image,
      imageAsset: widget.imageAsset,
      title: widget.title,
      description: widget.message,
      buttonLabel: widget.retryLabel,
      buttonIcon: Icons.refresh_rounded,
      buttonLoading: _reconnecting,
      onPressed: widget.onRetry,
      showImage: widget.showImage,
      showTitle: widget.showTitle,
      showDescription: widget.showDescription,
      showButton: widget.showButton,
      compact: widget.compact,
      footer: _reconnecting
          ? Text(StateStrings.reconnecting, style: AppTextStyles.caption)
          : null,
    );
  }
}

/// Dữ liệu trống. Truyền [onAdd] để hiện nút "Thêm mới" (đổi chữ bằng [addLabel]).
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    this.title = StateStrings.emptyTitle,
    this.message,
    this.icon,
    this.onAdd,
    this.addLabel = StateStrings.addNew,
    this.addIcon = Icons.add_rounded,
    this.action,
    this.image,
    this.imageAsset,
    this.showImage = true,
    this.showTitle = true,
    this.showDescription = true,
    this.showButton = true,
    this.compact = false,
  });

  final String title;

  /// Mô tả thêm dưới tiêu đề.
  final String? message;

  /// Biểu tượng chính trên ảnh minh hoạ (mặc định là hộp trống).
  final IconData? icon;
  final VoidCallback? onAdd;
  final String addLabel;
  final IconData addIcon;

  /// Khối hành động tuỳ chỉnh thay cho nút "Thêm mới" (ví dụ "Khám phá cơ sở").
  final Widget? action;
  final Widget? image;
  final String? imageAsset;
  final bool showImage;
  final bool showTitle;
  final bool showDescription;
  final bool showButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      illustration: AppIllustrationType.empty,
      icon: icon,
      image: image,
      imageAsset: imageAsset,
      title: title,
      description: message,
      buttonLabel: addLabel,
      buttonIcon: addIcon,
      onPressed: onAdd,
      action: action,
      showImage: showImage,
      showTitle: showTitle,
      showDescription: showDescription,
      showButton: showButton,
      compact: compact,
    );
  }
}

/// Chọn component theo nhóm lỗi: mất mạng → [AppOfflineView]; máy chủ lỗi hoặc
/// lỗi không xác định → [AppErrorView]; lỗi yêu cầu (không có quyền, không tìm
/// thấy…) → thông báo cụ thể.
class AppFailureView extends StatelessWidget {
  const AppFailureView({
    super.key,
    required this.message,
    this.kind,
    this.onRetry,
    this.compact = false,
  });

  factory AppFailureView.fromState(
    LoadState<Object?> state, {
    Key? key,
    VoidCallback? onRetry,
    bool compact = false,
  }) =>
      AppFailureView(
        key: key,
        message: state.error ?? ErrorStrings.unknown,
        kind: state.errorKind,
        onRetry: onRetry,
        compact: compact,
      );

  factory AppFailureView.fromError(
    Object error, {
    Key? key,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    final exception = AppException.from(error);
    return AppFailureView(
      key: key,
      message: exception.message,
      kind: exception.kind,
      onRetry: onRetry,
      compact: compact,
    );
  }

  final String message;
  final AppErrorKind? kind;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final errorKind = kind ?? AppErrorKind.unknown;
    if (errorKind == AppErrorKind.network) {
      return AppOfflineView(onRetry: onRetry, compact: compact);
    }
    if (errorKind.isSystem) {
      return AppErrorView(message: message, onRetry: onRetry, compact: compact);
    }
    return AppErrorView(
      title: StateStrings.requestErrorTitle,
      message: message,
      illustration: AppIllustrationType.requestError,
      onRetry: onRetry,
      compact: compact,
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
    return AppStateView(
      illustration: AppIllustrationType.login,
      icon: icon,
      title: title,
      description: message,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: AppStrings.login, onPressed: onLogin, expand: true),
          if (onRegister != null) ...[
            const Gap(AppSpacing.xs),
            AppButton.text(label: AppStrings.register, onPressed: onRegister),
          ],
        ],
      ),
    );
  }
}

/// Dựng giao diện theo [LoadState]: đang tải → vòng xoay; lỗi → component theo
/// nhóm lỗi (mất mạng / lỗi hệ thống / lỗi yêu cầu); có dữ liệu → [builder].
/// Khi tải lại, dữ liệu cũ vẫn hiển thị.
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
      return AppFailureView.fromState(state, onRetry: onRetry);
    }
    return loading ?? const AppLoadingView();
  }
}
