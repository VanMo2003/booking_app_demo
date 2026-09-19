import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/app_colors.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';

@injectable
class RoomAdminCubit extends LoadCubit<RoomDetail> {
  RoomAdminCubit(this._getDetail);

  final GetRoomDetail _getDetail;
  late int _roomId;

  Future<void> start(int roomId) {
    _roomId = roomId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getDetail(_roomId));
}

enum _RoomMenu { upload, amenities, delete }

/// Chi tiết phòng phía cơ sở: ảnh, thông tin, tiện ích, đổi trạng thái.
/// Quản trị viên chỉ xem.
@RoutePage()
class RoomManageDetailScreen extends StatelessWidget {
  const RoomManageDetailScreen({
    super.key,
    required this.hotelId,
    required this.roomId,
  });

  final int hotelId;
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RoomAdminCubit>()..start(roomId),
      child: _RoomManageDetailView(hotelId: hotelId, roomId: roomId),
    );
  }
}

class _RoomManageDetailView extends StatelessWidget {
  const _RoomManageDetailView({required this.hotelId, required this.roomId});

  final int hotelId;
  final int roomId;

  Future<void> _reload(BuildContext context) => context.read<RoomAdminCubit>().load();

  Future<void> _edit(BuildContext context, Room room) async {
    final saved = await context.router.push<bool>(RoomFormRoute(hotelId: hotelId, room: room));
    if (saved == true && context.mounted) await _reload(context);
  }

  Future<void> _upload(BuildContext context) async {
    final files = await ImagePickerHelper.pick();
    if (files.isEmpty || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<UploadRoomImages>()(roomId, files)),
      successMessage: WorkspaceStrings.imagesUploaded,
    );
    if (result.isSuccess && context.mounted) await _reload(context);
  }

  Future<void> _toggleStatus(BuildContext context, Room room) async {
    final next = room.status == RoomStatus.maintenance
        ? RoomStatus.available
        : RoomStatus.maintenance;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<SetRoomStatus>()(room, next)),
      successMessage: WorkspaceStrings.roomStatusUpdated,
    );
    if (result.isSuccess && context.mounted) await _reload(context);
  }

  Future<void> _delete(BuildContext context, Room room) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(ExploreStrings.roomTitle(room.roomNumber)),
      confirmLabel: AppStrings.delete,
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteRoom>()(room.id)),
      successMessage: WorkspaceStrings.roomDeleted,
    );
    if (result.isSuccess && context.mounted) await context.router.maybePop(true);
  }

  PopupMenuItem<_RoomMenu> _menuItem(
    _RoomMenu value,
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.danger : AppColors.ink;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: destructive ? AppColors.danger : AppColors.inkSecondary),
          const Gap(AppSpacing.sm),
          Text(label, style: AppTextStyles.body.colored(color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select((SessionCubit cubit) => cubit.state.role);
    final canManage = role?.isManagerOrAbove ?? false;
    final canEdit = role?.canEditBranchContent ?? false;
    return BlocBuilder<RoomAdminCubit, LoadState<RoomDetail>>(
      builder: (context, state) {
        final room = state.data?.room;
        final canToggle = room != null &&
            (room.status == RoomStatus.available || room.status == RoomStatus.maintenance);
        return AppPage(
          title: room == null
              ? ExploreStrings.roomDetailTitle
              : ExploreStrings.roomTitle(room.roomNumber),
          subtitle: (room?.roomTypeName ?? '').isEmpty ? null : room!.roomTypeName,
          actions: [
            if (room != null && canEdit)
              PopupMenuButton<_RoomMenu>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case _RoomMenu.upload:
                      _upload(context);
                    case _RoomMenu.amenities:
                      context.router.push(AmenitiesRoute(hotelId: hotelId));
                    case _RoomMenu.delete:
                      _delete(context, room);
                  }
                },
                itemBuilder: (_) => [
                  _menuItem(
                    _RoomMenu.upload,
                    Icons.add_photo_alternate_outlined,
                    WorkspaceStrings.uploadImages,
                  ),
                  _menuItem(
                    _RoomMenu.amenities,
                    Icons.checklist_rounded,
                    WorkspaceStrings.manageAmenities,
                  ),
                  if (canManage)
                    _menuItem(
                      _RoomMenu.delete,
                      Icons.delete_outline_rounded,
                      AppStrings.delete,
                      destructive: true,
                    ),
                ],
              ),
          ],
          body: LoadStateView<RoomDetail>(
            state: state,
            onRetry: () => _reload(context),
            builder: (context, detail) => RefreshIndicator(
              onRefresh: () => _reload(context),
              child: _RoomBody(detail: detail, hotelId: hotelId, canEdit: canEdit),
            ),
          ),
          bottomBar: room == null || !canEdit
              ? null
              : BottomActionBar(
                  child: Row(
                    children: [
                      AppButton.secondary(
                        label: AppStrings.edit,
                        icon: Icons.edit_outlined,
                        onPressed: () => _edit(context, room),
                      ),
                      if (canToggle) ...[
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: AppButton.tonal(
                            label: room.status == RoomStatus.maintenance
                                ? WorkspaceStrings.setAvailable
                                : WorkspaceStrings.setMaintenance,
                            icon: room.status == RoomStatus.maintenance
                                ? Icons.lock_open_rounded
                                : Icons.build_outlined,
                            onPressed: () => _toggleStatus(context, room),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _RoomBody extends StatelessWidget {
  const _RoomBody({required this.detail, required this.hotelId, required this.canEdit});

  final RoomDetail detail;
  final int hotelId;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final room = detail.room;
    return ListView(
      padding: AppSpacing.page,
      children: [
        ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ImageCarousel(paths: detail.gallery, placeholderIcon: Icons.bed_rounded),
          ),
        ),
        const Gap(AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(
                label: WorkspaceStrings.status,
                value: '',
                valueWidget: StatusBadge.room(room.status, dense: true),
              ),
              InfoRow(
                label: WorkspaceStrings.roomType,
                value: room.roomTypeName.isEmpty ? AppStrings.notUpdated : room.roomTypeName,
              ),
              InfoRow(
                label: WorkspaceStrings.priceLabel,
                value: Fmt.money(room.price),
                valueStyle: AppTextStyles.money.colored(AppColors.primaryDark),
              ),
              InfoRow(
                label: WorkspaceStrings.capacityLabel,
                value: AppStrings.guests(room.capacity),
              ),
            ],
          ),
        ),
        if (room.description.isNotEmpty) ...[
          const Gap(AppSpacing.lg),
          const SectionHeader(title: WorkspaceStrings.description),
          const Gap(AppSpacing.xs),
          ExpandableText(room.description),
        ],
        const Gap(AppSpacing.lg),
        SectionHeader(
          title: ExploreStrings.roomAmenities,
          actionLabel: canEdit ? WorkspaceStrings.manageAmenities : WorkspaceStrings.viewAmenities,
          onAction: () => context.router.push(AmenitiesRoute(hotelId: hotelId)),
        ),
        const Gap(AppSpacing.xs),
        if (detail.amenities.isEmpty)
          Text(WorkspaceStrings.roomNoAmenities, style: AppTextStyles.bodySmall)
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final amenity in detail.amenities)
                SoftTag(label: amenity.name, icon: Icons.check_rounded, tone: StatusTone.brand),
            ],
          ),
      ],
    );
  }
}
