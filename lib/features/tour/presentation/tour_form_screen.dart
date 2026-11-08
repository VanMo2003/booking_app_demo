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
import '../../room/domain/entities/room.dart';
import '../../room/domain/usecases/room_usecases.dart';
import '../data/models/tour_models.dart';
import '../domain/entities/tour.dart';
import '../domain/usecases/tour_usecases.dart';
import 'widgets/tour_discover_widgets.dart';
import '../domain/entities/travel_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/text/discover_strings.dart';

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
  late final _stayNights = TextEditingController(text: '${widget.tour?.stayNights ?? 1}');
  late final _roomIds = <int>{...?widget.tour?.rooms.map((room) => room.roomId)};
  late final Future<List<Room>> _branchRooms = getIt<GetBranchRooms>()(widget.hotelId)
      .then((rooms) => [...rooms]..sort((a, b) => a.price.compareTo(b.price)));
  late bool _available = widget.tour?.available ?? true;
  late final _destination = TextEditingController(text: widget.tour?.destination);
  late final _childPrice = TextEditingController(text: ThousandsInputFormatter.format(widget.tour?.childPrice));
  late final _policy = TextEditingController(text: widget.tour?.cancellationPolicy);
  late final _discount = TextEditingController(text: widget.tour?.discountPercent?.toString());
  late Set<TravelTheme> _themes = {...?widget.tour?.themes};
  late final List<_StepFields> _steps = [
    for (final step in widget.tour?.itinerary ?? const <ItineraryStep>[]) _StepFields(step),
  ];
  late bool _featured = widget.tour?.featured ?? false;
  late DateTime? _promotionEndsAt = widget.tour?.promotionEndsAt;
  bool _saving = false;

  bool get _isEdit => widget.tour != null;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _price,
      _duration,
      _departure,
      _includes,
      _maxGuests,
      _description,
      _stayNights,
      _destination,
      _childPrice,
      _policy,
      _discount,
    ]) {
      controller.dispose();
    }
    for (final step in _steps) {
      step.dispose();
    }
    _photo.dispose();
    super.dispose();
  }

  String? _validateMaxGuests(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return Validators.positiveInt(text);
  }

  String? _validateNights(String? value) {
    final nights = int.tryParse(value?.trim() ?? '');
    if (nights == null || nights < 1 || nights > 30) return 'Từ 1 đến 30 đêm';
    return null;
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
      stayNights: int.parse(_stayNights.text.trim()),
      roomIds: _roomIds.toList(),
      destination: _destination.text.trim(),
      themes: _themes.toList(),
      itinerary: [
        for (final step in _steps)
          if (step.title.text.trim().isNotEmpty)
            ItineraryStep(
              time: step.time.text.trim().isEmpty ? null : step.time.text.trim(),
              title: step.title.text.trim(),
              description: step.description.text.trim().isEmpty ? null : step.description.text.trim(),
            ),
      ],
      childPrice: Validators.parseMoney(_childPrice.text) ?? 0,
      cancellationPolicy: _policy.text.trim(),
      featured: _featured,
      discountPercent: int.tryParse(_discount.text.trim()) ?? 0,
      promotionEndsAt: _promotionEndsAt,
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
            AppTextField(
              controller: _destination,
              label: TourFormStrings.destination,
              hint: TourFormStrings.destinationHint,
              prefixIcon: Icons.place_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const Gap(AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppMoneyField(controller: _price, label: TourFormStrings.adultPrice, validator: Validators.money),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: AppMoneyField(
                    controller: _childPrice,
                    label: TourFormStrings.childPrice,
                    helper: TourFormStrings.childPriceHint,
                  ),
                ),
              ],
            ),
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
            const Gap(AppSpacing.xl),
            const GroupLabel(TourFormStrings.themes),
            Text(TourFormStrings.themesHint, style: AppTextStyles.caption),
            const Gap(AppSpacing.xs),
            ThemePicker(selected: _themes, onChanged: (next) => setState(() => _themes = next)),
            const Gap(AppSpacing.xl),
            const GroupLabel(TourFormStrings.itinerary),
            Text(TourFormStrings.itineraryHint, style: AppTextStyles.caption),
            for (var i = 0; i < _steps.length; i++) ...[
              const Gap(AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(TourFormStrings.step(i + 1), style: AppTextStyles.captionStrong),
                        const Spacer(),
                        IconButton(
                          tooltip: TourFormStrings.removeStep,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                    _steps.removeAt(i).dispose();
                                  }),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 110,
                                child: AppTextField(controller: _steps[i].time, label: TourFormStrings.stepTime),
                              ),
                              const Gap(AppSpacing.sm),
                              Expanded(
                                child: AppTextField(
                                  controller: _steps[i].title,
                                  label: TourFormStrings.stepTitle,
                                  textCapitalization: TextCapitalization.sentences,
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.xs),
                          AppTextField(
                            controller: _steps[i].description,
                            label: TourFormStrings.stepDescription,
                            minLines: 1,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving || _steps.length >= 30 ? null : () => setState(() => _steps.add(_StepFields())),
                icon: const Icon(Icons.add_rounded),
                label: const Text(TourFormStrings.addStep),
              ),
            ),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: _policy,
              label: TourFormStrings.cancellation,
              hint: TourFormStrings.cancellationHint,
              prefixIcon: Icons.event_busy_outlined,
              minLines: 2,
              maxLines: 5,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.xl),
            const GroupLabel(TourFormStrings.promotion),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _discount,
                    label: TourFormStrings.discount,
                    hint: TourFormStrings.discountHint,
                    prefixIcon: Icons.local_offer_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final n = int.tryParse(value?.trim() ?? '');
                      return n != null && n > 90 ? TourFormStrings.discountMax : null;
                    },
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: AppDateField(
                    label: TourFormStrings.promotionEnds,
                    value: _promotionEndsAt ?? DateOnly.today().add(const Duration(days: 30)),
                    firstDate: DateOnly.today(),
                    onChanged: (day) => setState(() => _promotionEndsAt = day),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _featured,
              onChanged: (value) => setState(() => _featured = value),
              title: Text(TourFormStrings.featured, style: AppTextStyles.bodyMedium),
              subtitle: Text(TourFormStrings.featuredHint, style: AppTextStyles.caption),
            ),
            const Gap(AppSpacing.xl),
            const GroupLabel(TourStrings.roomsSection),
            Text(TourStrings.roomsHint, style: AppTextStyles.caption),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _stayNights,
              label: TourStrings.stayNights,
              hint: TourStrings.stayNightsHint,
              prefixIcon: Icons.nights_stay_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateNights,
            ),
            const Gap(AppSpacing.xs),
            FutureBuilder<List<Room>>(
              future: _branchRooms,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(TourStrings.roomsLoadFailed, style: AppTextStyles.caption);
                }
                final rooms = snapshot.data;
                if (rooms == null) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final room in rooms)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _roomIds.contains(room.id),
                        onChanged: _saving
                            ? null
                            : (checked) => setState(() {
                                  if (checked ?? false) {
                                    _roomIds.add(room.id);
                                  } else {
                                    _roomIds.remove(room.id);
                                  }
                                }),
                        title: Text('Phòng ${room.roomNumber} · ${room.roomTypeName}', style: AppTextStyles.bodyMedium),
                        subtitle: Text(TourStrings.capacity(room.capacity), style: AppTextStyles.caption),
                        secondary: PriceText(room.price, unit: TourStrings.perNight),
                      ),
                    Text(TourStrings.roomsSelected(_roomIds.length), style: AppTextStyles.captionStrong),
                  ],
                );
              },
            ),
            const Gap(AppSpacing.md),
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

/// Ô nhập của một chặng lịch trình.
class _StepFields {
  _StepFields([ItineraryStep? step])
      : time = TextEditingController(text: step?.time),
        title = TextEditingController(text: step?.title),
        description = TextEditingController(text: step?.description);

  final TextEditingController time;
  final TextEditingController title;
  final TextEditingController description;

  void dispose() {
    time.dispose();
    title.dispose();
    description.dispose();
  }
}
