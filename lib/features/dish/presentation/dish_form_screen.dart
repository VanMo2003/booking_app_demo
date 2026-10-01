import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
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
  late final _photo = PhotoPickerController(initialPath: widget.dish?.pathImage);
  late DishCategory _category = widget.dish?.category ?? DishCategory.mainCourse;
  late bool _available = widget.dish?.available ?? true;
  bool _saving = false;

  bool get _isEdit => widget.dish != null;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _photo.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final request = DishRequest(
      name: _name.text.trim(),
      price: Validators.parseMoney(_price.text) ?? 0,
      category: _category,
      description: _description.text.trim(),
      pathImage: _photo.pathForRequest,
      available: _available,
      hotelId: _isEdit ? null : widget.hotelId,
    );
    final result = await runAction(
      () => getIt<SaveDish>()(request, id: widget.dish?.id, image: _photo.picked),
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
            PhotoPickerField(
              controller: _photo,
              title: MenuStrings.photo,
              hint: MenuStrings.photoHint,
              placeholderIcon: Icons.restaurant_rounded,
              enabled: !_saving,
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
