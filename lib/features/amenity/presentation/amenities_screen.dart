import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../hotel/domain/entities/hotel.dart';
import '../../hotel/presentation/branch/branch_cubit.dart';
import '../../room/domain/entities/room.dart';
import '../data/models/amenity_models.dart';
import '../domain/entities/amenity.dart';
import '../domain/usecases/amenity_usecases.dart';

/// Tiện ích của cơ sở: tiện ích chung và tiện ích gắn theo phòng.
/// Danh sách lấy từ chi tiết cơ sở vì API theo cơ sở chỉ trả tiện ích chung.
@RoutePage()
class AmenitiesScreen extends StatelessWidget {
  const AmenitiesScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchCubit>()..loadBranch(hotelId),
      child: _AmenitiesView(hotelId: hotelId),
    );
  }
}

enum _AmenityMenu { edit, link, delete }

class _AmenitiesView extends StatefulWidget {
  const _AmenitiesView({required this.hotelId});

  final int hotelId;

  @override
  State<_AmenitiesView> createState() => _AmenitiesViewState();
}

class _AmenitiesViewState extends State<_AmenitiesView> {
  bool _common = true;

  Future<void> _reload() => context.read<BranchCubit>().load();

  Future<void> _openForm(List<Room> rooms, {Amenity? amenity}) async {
    final saved = await AppDialogs.sheet<bool>(
      context,
      title: amenity == null ? WorkspaceStrings.addAmenity : WorkspaceStrings.editAmenity,
      builder: (_) => _AmenityForm(
        hotelId: widget.hotelId,
        rooms: rooms,
        amenity: amenity,
        initialCommon: _common,
      ),
    );
    if (saved != true || !mounted) return;
    AppToast.success(context, WorkspaceStrings.amenitySaved);
    await _reload();
  }

  Future<void> _linkToRoom(Amenity amenity, List<Room> rooms) async {
    final roomId = await AppDialogs.choose<int>(
      context,
      title: WorkspaceStrings.linkToRoom,
      choices: [
        for (final room in rooms)
          AppChoice(value: room.id, label: room.title, icon: Icons.meeting_room_outlined),
      ],
    );
    if (roomId == null || !mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(
        () => getIt<LinkAmenityToRoom>()(roomId: roomId, amenityId: amenity.id),
      ),
      successMessage: WorkspaceStrings.linkedToRoom,
    );
    if (result.isSuccess && mounted) await _reload();
  }

  Future<void> _delete(Amenity amenity) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(amenity.name),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteAmenity>()(amenity.id)),
      successMessage: WorkspaceStrings.amenityDeleted,
    );
    if (result.isSuccess && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = context.select(
      (SessionCubit cubit) => cubit.state.role?.isManagerOrAbove ?? false,
    );
    return BlocBuilder<BranchCubit, LoadState<HotelDetail>>(
      builder: (context, state) {
        final loaded = state.data;
        return AppPage(
          title: WorkspaceStrings.amenitiesTitle,
          subtitle: loaded?.hotel.name,
          // Danh sách đang xem trống thì nút thêm nằm ngay trong trạng thái rỗng.
          floatingActionButton: loaded == null ||
                  !loaded.hotel.amenities.any((amenity) => amenity.common == _common)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(loaded.rooms),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(WorkspaceStrings.addAmenity),
                ),
          body: LoadStateView<HotelDetail>(
            state: state,
            onRetry: _reload,
            builder: (context, detail) {
              final common = detail.hotel.amenities.where((a) => a.common).toList();
              final byRoom = detail.hotel.amenities.where((a) => !a.common).toList();
              final visible = _common ? common : byRoom;
              return Column(
                children: [
                  const Gap(AppSpacing.xs),
                  ChoiceChipBar<bool>(
                    options: const [true, false],
                    selected: _common,
                    labelOf: (isCommon) => isCommon
                        ? WorkspaceStrings.commonAmenities
                        : WorkspaceStrings.roomAmenities,
                    countOf: (isCommon) => isCommon ? common.length : byRoom.length,
                    onSelected: (isCommon) => setState(() => _common = isCommon),
                  ),
                  const Gap(AppSpacing.xs),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _reload,
                      child: visible.isEmpty
                          ? ListView(
                              children: [
                                const Gap(AppSpacing.xxl),
                                AppEmptyView(
                                  icon: Icons.checklist_rounded,
                                  title: _common
                                      ? WorkspaceStrings.amenitiesEmpty
                                      : WorkspaceStrings.amenitiesRoomEmpty,
                                  addLabel: WorkspaceStrings.addAmenity,
                                  onAdd: () => _openForm(detail.rooms),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                AppSpacing.bottomBarClearance,
                              ),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                              itemBuilder: (context, index) {
                                final amenity = visible[index];
                                return _AmenityTile(
                                  amenity: amenity,
                                  canLink: detail.rooms.isNotEmpty,
                                  canDelete: canDelete,
                                  onTap: () => _openForm(detail.rooms, amenity: amenity),
                                  onSelected: (action) {
                                    switch (action) {
                                      case _AmenityMenu.edit:
                                        _openForm(detail.rooms, amenity: amenity);
                                      case _AmenityMenu.link:
                                        _linkToRoom(amenity, detail.rooms);
                                      case _AmenityMenu.delete:
                                        _delete(amenity);
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AmenityTile extends StatelessWidget {
  const _AmenityTile({
    required this.amenity,
    required this.canLink,
    required this.canDelete,
    required this.onTap,
    required this.onSelected,
  });

  final Amenity amenity;
  final bool canLink;
  final bool canDelete;
  final VoidCallback onTap;
  final ValueChanged<_AmenityMenu> onSelected;

  @override
  Widget build(BuildContext context) {
    final roomName = amenity.roomName ?? '';
    final tone = amenity.common ? StatusTone.brand : StatusTone.info;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              amenity.common ? Icons.done_all_rounded : Icons.meeting_room_outlined,
              size: 20,
              color: tone.colors.foreground,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amenity.name, style: AppTextStyles.bodyStrong),
                if (amenity.description.isNotEmpty)
                  Text(
                    amenity.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!amenity.common && roomName.isNotEmpty) ...[
                  const Gap(4),
                  SoftTag(label: WorkspaceStrings.amenityInRoom(roomName), tone: StatusTone.info),
                ],
              ],
            ),
          ),
          PopupMenuButton<_AmenityMenu>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkTertiary),
            onSelected: onSelected,
            itemBuilder: (_) => [
              const PopupMenuItem(value: _AmenityMenu.edit, child: Text(AppStrings.edit)),
              if (canLink)
                const PopupMenuItem(
                  value: _AmenityMenu.link,
                  child: Text(WorkspaceStrings.linkToRoom),
                ),
              if (canDelete)
                PopupMenuItem(
                  value: _AmenityMenu.delete,
                  child: Text(
                    AppStrings.delete,
                    style: AppTextStyles.body.colored(AppColors.danger),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmenityForm extends StatefulWidget {
  const _AmenityForm({
    required this.hotelId,
    required this.rooms,
    this.amenity,
    this.initialCommon = true,
  });

  final int hotelId;
  final List<Room> rooms;
  final Amenity? amenity;
  final bool initialCommon;

  @override
  State<_AmenityForm> createState() => _AmenityFormState();
}

class _AmenityFormState extends State<_AmenityForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.amenity?.name);
  late final _description = TextEditingController(text: widget.amenity?.description);
  late bool _common = widget.amenity?.common ?? widget.initialCommon;
  int? _roomId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.amenity != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final amenity = widget.amenity;
    final name = _name.text.trim();
    final description = _description.text.trim();
    final result = await runAction(
      () => amenity == null
          ? getIt<CreateAmenity>()(
              AmenityCreateRequest(
                name: name,
                hotelId: widget.hotelId,
                description: description,
                common: _common,
                roomId: _common ? null : _roomId,
              ),
            )
          : getIt<UpdateAmenity>()(
              amenity.id,
              AmenityUpdateRequest(name: name, description: description, common: _common),
            ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.rooms;
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            label: WorkspaceStrings.amenityName,
            prefixIcon: Icons.checklist_rounded,
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required(),
          ),
          const Gap(AppSpacing.sm),
          AppTextField(
            controller: _description,
            label: WorkspaceStrings.amenityDescription,
            minLines: 2,
            maxLines: 3,
          ),
          const Gap(AppSpacing.xs),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _common,
            onChanged: (value) => setState(() => _common = value),
            title: Text(WorkspaceStrings.amenityCommon, style: AppTextStyles.bodyMedium),
            subtitle: Text(WorkspaceStrings.amenityCommonHint, style: AppTextStyles.caption),
          ),
          if (!_common && !_isEdit) ...[
            const Gap(AppSpacing.xs),
            AppDropdownField<int>(
              label: WorkspaceStrings.amenityRoom,
              prefixIcon: Icons.meeting_room_outlined,
              items: rooms.map((room) => room.id).toList(),
              value: _roomId,
              itemLabel: (id) =>
                  rooms.where((room) => room.id == id).map((room) => room.title).firstOrNull ??
                  '#$id',
              validator: (value) => value == null ? WorkspaceStrings.amenityRoomRequired : null,
              onChanged: (value) => setState(() => _roomId = value),
            ),
          ],
          if (_error != null) ...[
            const Gap(AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.lg),
          AppButton(label: AppStrings.save, expand: true, loading: _saving, onPressed: _submit),
        ],
      ),
    );
  }
}
