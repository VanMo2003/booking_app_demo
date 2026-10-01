import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/tour_strings.dart';
import '../../../core/utils/validators.dart';
import '../data/models/tour_models.dart';
import '../domain/entities/tour.dart';
import '../domain/usecases/tour_usecases.dart';

/// Thêm hoặc sửa tour. Ảnh chọn từ máy hoặc dán link. Trả `true` khi đã lưu.
@RoutePage()
class TourFormScreen extends StatefulWidget {
  const TourFormScreen({super.key, required this.hotelId, this.tour});

  final int hotelId;
  final Tour? tour;

  @override
  State<TourFormScreen> createState() => _TourFormScreenState();
}

class _TourFormScreenState extends State<TourFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.tour?.name);
  late final _price = TextEditingController(text: ThousandsInputFormatter.format(widget.tour?.price));
  late final _duration = TextEditingController(text: widget.tour?.duration);
  late final _departure = TextEditingController(text: widget.tour?.departure);
  late final _includes = TextEditingController(text: widget.tour?.includes);
  late final _maxGuests = TextEditingController(text: widget.tour?.maxGuests?.toString());
  late final _description = TextEditingController(text: widget.tour?.description);
  late final _photo = PhotoPickerController(initialPath: widget.tour?.pathImage);
  late bool _available = widget.tour?.available ?? true;
  bool _saving = false;

  bool get _isEdit => widget.tour != null;

  @override
  void dispose() {
    for (final controller in [_name, _price, _duration, _departure, _includes, _maxGuests, _description]) {
      controller.dispose();
    }
    _photo.dispose();
    super.dispose();
  }

  String? _validateMaxGuests(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return Validators.positiveInt(text);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final request = TourRequest(
      name: _name.text.trim(),
      price: Validators.parseMoney(_price.text) ?? 0,
      duration: _duration.text.trim(),
      departure: _departure.text.trim(),
      includes: _includes.text.trim(),
      maxGuests: int.tryParse(_maxGuests.text.trim()),
      description: _description.text.trim(),
      pathImage: _photo.pathForRequest,
      available: _available,
      hotelId: _isEdit ? null : widget.hotelId,
    );
    final result = await runAction(
      () => getIt<SaveTour>()(request, id: widget.tour?.id, image: _photo.picked),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, TourStrings.saved);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _isEdit ? TourStrings.editTour : TourStrings.addTour,
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            PhotoPickerField(
              controller: _photo,
              title: TourStrings.photo,
              hint: TourStrings.photoHint,
              placeholderIcon: Icons.tour_outlined,
              enabled: !_saving,
            ),
            const Gap(AppSpacing.xl),
            const GroupLabel(TourStrings.tourInfo),
            AppTextField(
              controller: _name,
              label: TourStrings.name,
              hint: TourStrings.nameHint,
              prefixIcon: Icons.tour_outlined,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: Validators.required(),
            ),
            const Gap(AppSpacing.sm),
            AppMoneyField(controller: _price, label: TourStrings.price, validator: Validators.money),
            const Gap(AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _duration,
                    label: TourStrings.duration,
                    hint: TourStrings.durationHint,
                    prefixIcon: Icons.timelapse_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    controller: _maxGuests,
                    label: TourStrings.maxGuests,
                    hint: TourStrings.maxGuestsHint,
                    prefixIcon: Icons.groups_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateMaxGuests,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _departure,
              label: TourStrings.departure,
              hint: TourStrings.departureHint,
              prefixIcon: Icons.schedule_rounded,
              textInputAction: TextInputAction.next,
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _includes,
              label: TourStrings.includes,
              hint: TourStrings.includesHint,
              prefixIcon: Icons.checklist_rounded,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _description,
              label: TourStrings.description,
              hint: TourStrings.descriptionHint,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _available,
              onChanged: (value) => setState(() => _available = value),
              title: Text(
                _available ? TourStrings.running : TourStrings.paused,
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: Text(TourStrings.availableHint, style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(label: AppStrings.save, expand: true, loading: _saving, onPressed: _submit),
      ),
    );
  }
}
