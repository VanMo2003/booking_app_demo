import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/upload_file.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/validation_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../catalog/domain/entities/catalog_item.dart';
import '../../../catalog/domain/usecases/catalog_usecases.dart';
import '../../data/models/room_models.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';

/// Thêm hoặc sửa phòng. Trả `true` khi đã lưu.
@RoutePage()
class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, required this.hotelId, this.room});

  final int hotelId;
  final Room? room;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _number = TextEditingController(text: widget.room?.roomNumber);
  late final _price = TextEditingController(
    text: ThousandsInputFormatter.format(widget.room?.price),
  );
  late final _capacity = TextEditingController(
    text: '${widget.room?.capacity ?? 2}',
  );
  late final _description = TextEditingController(text: widget.room?.description);
  late int? _roomTypeId = widget.room?.roomTypeId;
  late RoomStatus _status = widget.room?.status ?? RoomStatus.available;
  late Future<List<CatalogItem>> _roomTypes = _loadRoomTypes();
  final List<UploadFile> _images = [];
  bool _saving = false;

  bool get _isEdit => widget.room != null;

  Future<List<CatalogItem>> _loadRoomTypes() => getIt<GetCatalog>()(CatalogKind.roomType);

  @override
  void dispose() {
    _number.dispose();
    _price.dispose();
    _capacity.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await ImagePickerHelper.pick();
    if (files.isNotEmpty && mounted) setState(() => _images.addAll(files));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_roomTypeId == null) {
      AppToast.error(context, WorkspaceStrings.noRoomTypes);
      return;
    }
    setState(() => _saving = true);
    final request = RoomRequest(
      roomNumber: _number.text.trim(),
      price: Validators.parseMoney(_price.text) ?? 0,
      capacity: int.parse(_capacity.text.trim()),
      roomTypeId: _roomTypeId!,
      description: _description.text.trim(),
      status: _status,
      hotelId: _isEdit ? null : widget.hotelId,
    );
    final result = await runAction(() async {
      final room = await getIt<SaveRoom>()(request, id: widget.room?.id);
      if (_images.isNotEmpty) await getIt<UploadRoomImages>()(room.id, _images);
      return room;
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, WorkspaceStrings.roomSaved);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trạng thái Đã đặt/Đang có khách do đơn quyết định; tay chỉ chuyển Trống ↔ Bảo trì.
    final statuses = {RoomStatus.available, RoomStatus.maintenance, _status}.toList();
    return AppPage(
      title: _isEdit ? WorkspaceStrings.editRoom : WorkspaceStrings.addRoom,
      body: FutureBuilder<List<CatalogItem>>(
        future: _roomTypes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppFailureView.fromError(
              snapshot.error!,
              onRetry: () => setState(() => _roomTypes = _loadRoomTypes()),
            );
          }
          if (!snapshot.hasData) return const AppLoadingView();
          final roomTypes = snapshot.data!;
          return Form(
            key: _form,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                const GroupLabel(WorkspaceStrings.roomInfo),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _number,
                        label: WorkspaceStrings.roomNumber,
                        prefixIcon: Icons.meeting_room_outlined,
                        textInputAction: TextInputAction.next,
                        validator: Validators.required(),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        controller: _capacity,
                        label: WorkspaceStrings.capacityLabel,
                        prefixIcon: Icons.people_alt_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.positiveInt,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                if (roomTypes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.warningSoft,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      WorkspaceStrings.noRoomTypes,
                      style: AppTextStyles.bodySmall.colored(AppColors.warning),
                    ),
                  )
                else
                  AppDropdownField<int>(
                    label: WorkspaceStrings.roomType,
                    prefixIcon: Icons.category_outlined,
                    items: roomTypes.map((type) => type.id).toList(),
                    value: _roomTypeId,
                    itemLabel: (id) =>
                        roomTypes.where((type) => type.id == id).firstOrNull?.name ??
                        widget.room?.roomTypeName ??
                        '#$id',
                    validator: (value) => value == null ? ValidationStrings.required : null,
                    onChanged: (value) => setState(() => _roomTypeId = value),
                  ),
                const Gap(AppSpacing.sm),
                AppMoneyField(
                  controller: _price,
                  label: WorkspaceStrings.pricePerNight,
                  validator: Validators.money,
                ),
                const Gap(AppSpacing.sm),
                AppDropdownField<RoomStatus>(
                  label: WorkspaceStrings.status,
                  prefixIcon: Icons.toggle_on_outlined,
                  items: statuses,
                  value: _status,
                  itemLabel: (status) => status.label,
                  onChanged: (value) => setState(() => _status = value ?? _status),
                ),
                const Gap(AppSpacing.sm),
                AppTextField(
                  controller: _description,
                  label: WorkspaceStrings.description,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const Gap(AppSpacing.xl),
                const SectionHeader(
                  title: WorkspaceStrings.roomImages,
                  subtitle: WorkspaceStrings.roomImagesHint,
                ),
                const Gap(AppSpacing.sm),
                ImageGallery(
                  picked: _images,
                  onAdd: _pickImages,
                  onRemovePicked: (index) => setState(() => _images.removeAt(index)),
                  addLabel: WorkspaceStrings.uploadImages,
                ),
              ],
            ),
          );
        },
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
