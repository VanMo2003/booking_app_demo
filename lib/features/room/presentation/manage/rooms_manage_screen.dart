import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/text_search.dart';
import '../../../shell/presentation/workspace_scope.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';
import '../widgets/room_tile.dart';

@injectable
class RoomsManageCubit extends LoadCubit<List<Room>> {
  RoomsManageCubit(this._getRooms);

  final GetBranchRooms _getRooms;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getRooms(_hotelId));
}

/// Tab Phòng của không gian làm việc.
@RoutePage()
class RoomsManageScreen extends StatelessWidget {
  const RoomsManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelId = WorkspaceScope.of(context).hotelId;
    return BlocProvider(
      key: ValueKey(hotelId),
      create: (_) => getIt<RoomsManageCubit>()..start(hotelId),
      child: _RoomsManageView(hotelId: hotelId),
    );
  }
}

class _RoomsManageView extends StatefulWidget {
  const _RoomsManageView({required this.hotelId});

  final int hotelId;

  @override
  State<_RoomsManageView> createState() => _RoomsManageViewState();
}

class _RoomsManageViewState extends State<_RoomsManageView> {
  final _search = TextEditingController();
  RoomStatus? _status;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addRoom() async {
    final saved = await context.rootRouter.push<bool>(RoomFormRoute(hotelId: widget.hotelId));
    if (saved == true && mounted) await context.read<RoomsManageCubit>().load();
  }

  Future<void> _openRoom(Room room) async {
    await context.rootRouter.push(
      RoomManageDetailRoute(hotelId: widget.hotelId, roomId: room.id),
    );
    if (mounted) await context.read<RoomsManageCubit>().load();
  }

  bool _matches(Room room) {
    if (_status != null && room.status != _status) return false;
    final query = _query.trim();
    return query.isEmpty ||
        room.roomNumber.toLowerCase().contains(query.toLowerCase()) ||
        TextSearch.matches(room.roomTypeName, query);
  }

  @override
  Widget build(BuildContext context) {
    final branchName = context.branchName;
    return BlocBuilder<RoomsManageCubit, LoadState<List<Room>>>(
      builder: (context, state) {
        final cubit = context.read<RoomsManageCubit>();
        final rooms = state.data ?? const <Room>[];
        final visible = rooms.where(_matches).toList();
        return AppPage(
          title: WorkspaceStrings.roomsTitle,
          subtitle: [
            if (branchName != null) branchName,
            if (state.hasData) AppStrings.roomsCount(rooms.length),
          ].join(' · '),
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          // Khi chưa có phòng, nút thêm nằm ngay trong trạng thái rỗng.
          floatingActionButton: rooms.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: _addRoom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(WorkspaceStrings.addRoom),
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: AppSearchField(
                  controller: _search,
                  hint: WorkspaceStrings.roomsSearchHint,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              ChoiceChipBar<RoomStatus?>(
                options: const [null, ...RoomStatus.values],
                selected: _status,
                labelOf: (status) => status?.label ?? AppStrings.all,
                countOf: state.hasData
                    ? (status) => status == null
                        ? rooms.length
                        : rooms.where((room) => room.status == status).length
                    : null,
                onSelected: (status) => setState(() => _status = status),
              ),
              const Gap(AppSpacing.xs),
              if (state.isLoading && state.hasData) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: LoadStateView<List<Room>>(
                  state: state,
                  onRetry: cubit.load,
                  isEmpty: (data) => data.isEmpty,
                  empty: AppEmptyView(
                    icon: Icons.bed_outlined,
                    title: WorkspaceStrings.roomsEmpty,
                    message: WorkspaceStrings.roomsEmptyHint,
                    addLabel: WorkspaceStrings.addRoom,
                    onAdd: _addRoom,
                  ),
                  builder: (context, _) => RefreshIndicator(
                    onRefresh: cubit.load,
                    child: visible.isEmpty
                        ? ListView(
                            children: const [
                              Gap(AppSpacing.xxl),
                              AppEmptyView(
                                icon: Icons.search_off_rounded,
                                title: AppStrings.emptyTitle,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              AppSpacing.bottomBarClearance,
                            ),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                            itemBuilder: (context, index) => RoomTile(
                              room: visible[index],
                              onTap: () => _openRoom(visible[index]),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
