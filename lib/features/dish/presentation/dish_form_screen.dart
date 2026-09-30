import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/network/upload_file.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/menu_strings.dart';
import '../../../core/utils/validators.dart';
import '../data/models/dish_models.dart';
import '../domain/entities/dish.dart';
import '../domain/usecases/dish_usecases.dart';

/// Thêm hoặc sửa món. Ảnh chọn từ máy hoặc dán link. Trả `true` khi đã lưu.
@RoutePage()
class DishFormScreen extends StatefulWidget {
  const DishFormScreen({super.key, required this.hotelId, this.dish});

  final int hotelId;
  final Dish? dish;

  @override
  State<DishFormScreen> createState() => _DishFormScreenState();
}

class _DishFormScreenState extends State<DishFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.dish?.name);
  late final _price = TextEditingController(
    text: ThousandsInputFormatter.format(widget.dish?.price),
  );
  late final _description = TextEditingController(text: widget.dish?.description);

  /// Link ngoài hiện sẵn trong ô link để sửa; ảnh đã tải lên máy chủ thì giữ ở [_uploadedPath].
  late final _photoUrl = TextEditingController(
    text: _isExternal(widget.dish?.pathImage) ? widget.dish!.pathImage : null,
  );
  late String? _uploadedPath =
      _isExternal(widget.dish?.pathImage) ? null : widget.dish?.pathImage;
  late DishCategory _category = widget.dish?.category ?? DishCategory.mainCourse;
  late bool _available = widget.dish?.available ?? true;
  UploadFile? _picked;
  bool _saving = false;

  bool get _isEdit => widget.dish != null;

  static bool _isExternal(String? path) =>
      path != null && (path.startsWith('http://') || path.startsWith('https://'));

  @override
  void initState() {
    super.initState();
    // Xem trước đổi theo link đang gõ.
    _photoUrl.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    if (_photoUrl.text.trim().isNotEmpty && _picked != null) {
      setState(() => _picked = null);
    } else {
      setState(() {});
    }
  }

  Future<void> _pickPhoto() async {
    final files = await ImagePickerHelper.pick(multiple: false);
    if (files.isEmpty || !mounted) return;
    setState(() => _picked = files.first);
    _photoUrl.clear();
  }

  void _removePhoto() {
    setState(() {
      _picked = null;
      _uploadedPath = null;
    });
    _photoUrl.clear();
  }

  bool get _hasPhoto =>
      _picked != null || _photoUrl.text.trim().isNotEmpty || _uploadedPath != null;

  /// Giá trị `pathImage` gửi lên: link dán tay, `''` để gỡ ảnh cũ, `null` để giữ nguyên
  /// (hoặc khi ảnh chọn từ máy sẽ được tải lên sau).
  String? get _pathImageForRequest {
    if (_picked != null) return null;
    final url = _photoUrl.text.trim();
    if (url.isNotEmpty) return url;
    final hadPhoto = widget.dish?.pathImage != null;
    return _isEdit && hadPhoto && _uploadedPath == null ? '' : null;
  }

  String? _validateUrl(String? value) {
    final url = value?.trim() ?? '';
    return url.isEmpty || _isExternal(url) ? null : MenuStrings.photoUrlInvalid;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final request = DishRequest(
      name: _name.text.trim(),
      price: Validators.parseMoney(_price.text) ?? 0,
      category: _category,
      description: _description.text.trim(),
      pathImage: _pathImageForRequest,
      available: _available,
      hotelId: _isEdit ? null : widget.hotelId,
    );
    final result = await runAction(
      () => getIt<SaveDish>()(request, id: widget.dish?.id, image: _picked),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, MenuStrings.saved);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _isEdit ? MenuStrings.editDish : MenuStrings.addDish,
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            const SectionHeader(title: MenuStrings.photo, subtitle: MenuStrings.photoHint),
            const Gap(AppSpacing.sm),
            _PhotoPreview(
              picked: _picked,
              path: _photoUrl.text.trim().isNotEmpty && _validateUrl(_photoUrl.text) == null
                  ? _photoUrl.text.trim()
                  : _uploadedPath,
            ),
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: _hasPhoto ? MenuStrings.changePhoto : MenuStrings.pickPhoto,
                    icon: Icons.add_photo_alternate_outlined,
                    size: AppButtonSize.medium,
                    onPressed: _saving ? null : _pickPhoto,
                  ),
                ),
                if (_hasPhoto) ...[
                  const Gap(AppSpacing.sm),
                  AppButton.text(
                    label: MenuStrings.removePhoto,
                    icon: Icons.delete_outline_rounded,
                    onPressed: _saving ? null : _removePhoto,
                  ),
                ],
              ],
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _photoUrl,
              label: MenuStrings.photoUrl,
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              validator: _validateUrl,
            ),
            const Gap(AppSpacing.xl),
            const GroupLabel(MenuStrings.dishInfo),
            AppTextField(
              controller: _name,
              label: MenuStrings.name,
              prefixIcon: Icons.restaurant_rounded,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: Validators.required(),
            ),
            const Gap(AppSpacing.sm),
            AppDropdownField<DishCategory>(
              label: MenuStrings.category,
              prefixIcon: Icons.category_outlined,
              items: DishCategory.values,
              value: _category,
              itemLabel: (category) => category.label,
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const Gap(AppSpacing.sm),
            AppMoneyField(
              controller: _price,
              label: MenuStrings.price,
              validator: Validators.money,
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _description,
              label: MenuStrings.description,
              hint: MenuStrings.descriptionHint,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _available,
              onChanged: (value) => setState(() => _available = value),
              title: Text(
                _available ? MenuStrings.available : MenuStrings.unavailable,
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: Text(MenuStrings.availableHint, style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: AppStrings.save,
          expand: true,
          loading: _saving,
          onPressed: _submit,
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.picked, required this.path});

  final UploadFile? picked;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: picked != null
            ? Image.memory(picked!.bytes, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lineSoft),
                  borderRadius: AppRadius.mdAll,
                ),
                child: AppNetworkImage(path: path, placeholderIcon: Icons.restaurant_rounded),
              ),
      ),
    );
  }
}
