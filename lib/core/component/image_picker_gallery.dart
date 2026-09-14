import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../network/upload_file.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import 'app_network_image.dart';

abstract final class ImagePickerHelper {
  static Future<List<UploadFile>> pick({bool multiple = true}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: multiple,
      withData: true,
    );
    if (result == null) return const [];
    return result.files
        .where((file) => file.bytes != null)
        .map((file) => UploadFile(name: file.name, bytes: file.bytes!))
        .toList();
  }
}

/// Lưới ảnh: ảnh đã có trên máy chủ + ảnh vừa chọn + ô thêm ảnh.
class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    this.networkPaths = const [],
    this.picked = const [],
    this.coverPath,
    this.onAdd,
    this.onRemovePicked,
    this.onTapNetwork,
    this.addLabel,
    this.busy = false,
  });

  final List<String> networkPaths;
  final List<UploadFile> picked;
  final String? coverPath;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemovePicked;
  final ValueChanged<String>? onTapNetwork;
  final String? addLabel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final path in networkPaths)
        _Tile(
          onTap: onTapNetwork == null ? null : () => onTapNetwork!(path),
          selected: path == coverPath,
          child: AppNetworkImage(path: path),
        ),
      for (var i = 0; i < picked.length; i++)
        _Tile(
          onRemove: onRemovePicked == null ? null : () => onRemovePicked!(i),
          child: Image.memory(picked[i].bytes, fit: BoxFit.cover),
        ),
      if (onAdd != null)
        _AddTile(label: addLabel, onTap: busy ? null : onAdd, busy: busy),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.xs;
        final columns = constraints.maxWidth >= 520 ? 4 : 3;
        final size = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: size, height: size, child: tile),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.child,
    this.onTap,
    this.onRemove,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: AppRadius.smAll, child: child),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadius.smAll,
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.smAll,
                  border: selected
                      ? Border.all(color: AppColors.accent, width: 3)
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, size: 14, color: AppColors.onPrimary),
            ),
          ),
        if (onRemove != null)
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.onPrimary),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, this.label, this.busy = false});

  final VoidCallback? onTap;
  final String? label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft.withValues(alpha: 0.45),
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                    if (label != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        label!,
                        style: AppTextStyles.captionStrong.colored(AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
