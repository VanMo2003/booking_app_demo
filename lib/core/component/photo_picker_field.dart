import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../network/upload_file.dart';
import '../style/app_dimens.dart';
import '../text/app_strings.dart';
import 'app_button.dart';
import 'app_network_image.dart';
import 'app_text_field.dart';
import 'gap.dart';
import 'image_picker_gallery.dart';
import 'section_header.dart';

/// Trạng thái một ảnh trong biểu mẫu: ảnh đã có (tải lên máy chủ hoặc link
/// ngoài), ảnh vừa chọn từ máy, hoặc link vừa dán.
class PhotoPickerController extends ChangeNotifier {
  PhotoPickerController({String? initialPath}) : _initialPath = initialPath {
    url.text = isExternal(initialPath) ? initialPath! : '';
    _uploadedPath = isExternal(initialPath) ? null : initialPath;
    url.addListener(_onUrlChanged);
  }

  final String? _initialPath;

  /// Link ngoài hiện sẵn trong ô để sửa; ảnh đã tải lên máy chủ giữ ở [_uploadedPath].
  final url = TextEditingController();
  String? _uploadedPath;
  UploadFile? _picked;

  /// Ảnh chọn từ máy — tải lên sau khi lưu bản ghi.
  UploadFile? get picked => _picked;

  static bool isExternal(String? path) =>
      path != null && (path.startsWith('http://') || path.startsWith('https://'));

  bool get hasPhoto => _picked != null || url.text.trim().isNotEmpty || _uploadedPath != null;

  /// Đường dẫn để xem trước khi chưa chọn ảnh từ máy.
  String? get previewPath {
    final link = url.text.trim();
    return link.isNotEmpty && isExternal(link) ? link : _uploadedPath;
  }

  /// Giá trị `pathImage` gửi lên: link dán tay, `''` để gỡ ảnh cũ, `null` để giữ
  /// nguyên (hoặc khi ảnh chọn từ máy sẽ được tải lên sau).
  String? get pathForRequest {
    if (_picked != null) return null;
    final link = url.text.trim();
    if (link.isNotEmpty) return link;
    return _initialPath != null && _uploadedPath == null ? '' : null;
  }

  String? validateUrl(String? value) {
    final link = value?.trim() ?? '';
    return link.isEmpty || isExternal(link) ? null : AppStrings.photoUrlInvalid;
  }

  Future<void> pick() async {
    final files = await ImagePickerHelper.pick(multiple: false);
    if (files.isEmpty) return;
    _picked = files.first;
    url.clear();
    notifyListeners();
  }

  void remove() {
    _picked = null;
    _uploadedPath = null;
    url.clear();
    notifyListeners();
  }

  void _onUrlChanged() {
    // Dán link thì bỏ ảnh vừa chọn từ máy — chỉ giữ một nguồn.
    if (url.text.trim().isNotEmpty) _picked = null;
    notifyListeners();
  }

  @override
  void dispose() {
    url.dispose();
    super.dispose();
  }
}

/// Khối "Ảnh" của biểu mẫu: xem trước 16:9, nút chọn/đổi/xoá ảnh và ô dán link.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.controller,
    required this.title,
    this.hint,
    this.placeholderIcon = Icons.image_outlined,
    this.enabled = true,
  });

  final PhotoPickerController controller;
  final String title;
  final String? hint;
  final IconData placeholderIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final picked = controller.picked;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title, subtitle: hint),
            const Gap(AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: picked != null
                    ? Image.memory(picked.bytes, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lineSoft),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: AppNetworkImage(
                          path: controller.previewPath,
                          placeholderIcon: placeholderIcon,
                        ),
                      ),
              ),
            ),
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: controller.hasPhoto ? AppStrings.photoChange : AppStrings.photoPick,
                    icon: Icons.add_photo_alternate_outlined,
                    size: AppButtonSize.medium,
                    onPressed: enabled ? controller.pick : null,
                  ),
                ),
                if (controller.hasPhoto) ...[
                  const Gap(AppSpacing.sm),
                  AppButton.text(
                    label: AppStrings.photoRemove,
                    icon: Icons.delete_outline_rounded,
                    onPressed: enabled ? controller.remove : null,
                  ),
                ],
              ],
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: controller.url,
              label: AppStrings.photoUrl,
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              validator: controller.validateUrl,
            ),
          ],
        );
      },
    );
  }
}
