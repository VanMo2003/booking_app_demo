import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../config/app_config.dart';

/// Ảnh từ BE (`/uploads/...`). Không có ảnh hoặc tải lỗi thì hiện nền
/// chuyển màu kèm biểu tượng — không dùng ảnh mẫu từ internet.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.apartment_rounded,
  });

  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.resolveImageUrl(path);
    Widget child = url == null
        ? _ImagePlaceholder(icon: placeholderIcon, width: width, height: height)
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            frameBuilder: (context, image, frame, synchronous) {
              if (synchronous) return image;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                child: image,
              );
            },
            errorBuilder: (context, error, stackTrace) => _ImagePlaceholder(
              icon: Icons.image_not_supported_outlined,
              width: width,
              height: height,
            ),
          );
    if (url != null) {
      child = Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: _ImagePlaceholder(
              icon: placeholderIcon,
              width: width,
              height: height,
              showIcon: false,
            ),
          ),
          child,
        ],
      );
    }
    return borderRadius == null
        ? child
        : ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    this.width,
    this.height,
    this.showIcon = true,
  });

  final IconData icon;
  final double? width;
  final double? height;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.imagePlaceholderGradient,
      ),
      alignment: Alignment.center,
      child: !showIcon
          ? null
          : LayoutBuilder(
              builder: (context, constraints) {
                final shortest = math.min(
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 96,
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 96,
                );
                return Icon(
                  icon,
                  size: (shortest * 0.34).clamp(18, 44).toDouble(),
                  color: AppColors.primary.withValues(alpha: 0.45),
                );
              },
            ),
    );
  }
}
