import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/tour_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/tour.dart';
import '../domain/usecases/tour_usecases.dart';
import 'widgets/tour_card.dart';

/// Tour của một cơ sở — dùng chung cho màn quản lý và màn khách xem.
@injectable
class ToursCubit extends LoadCubit<List<Tour>> {
  ToursCubit(this._getTours);

  final GetBranchTours _getTours;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getTours(_hotelId));
}

/// Tour tham quan của cơ sở trong không gian làm việc. Chủ khách sạn và quản lý cơ sở
/// thêm, sửa, xoá; nhân viên và quản trị viên chỉ xem.
@RoutePage()
class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ToursCubit>()..start(hotelId),
      child: _ToursView(hotelId: hotelId),
    );
  }
}

enum _TourMenu { edit, toggle, delete }

class _ToursView extends StatelessWidget {
  const _ToursView({required this.hotelId});

  final int hotelId;

  Future<void> _openForm(BuildContext context, {Tour? tour}) async {
    final saved = await context.router.push<bool>(TourFormRoute(hotelId: hotelId, tour: tour));
    if (saved == true && context.mounted) await context.read<ToursCubit>().load();
  }

  Future<void> _toggle(BuildContext context, Tour tour) async {
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<SetTourAvailable>()(tour.id, !tour.available)),
      successMessage: tour.available ? TourStrings.markedPaused : TourStrings.markedRunning,
    );
    if (result.isSuccess && context.mounted) await context.read<ToursCubit>().load();
  }

  Future<void> _delete(BuildContext context, Tour tour) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(tour.name),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteTour>()(tour.id)),
      successMessage: TourStrings.deleted,
    );
    if (result.isSuccess && context.mounted) await context.read<ToursCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select((SessionCubit cubit) => cubit.state.role);
    final canEdit = role?.canManageTours ?? false;
    return BlocBuilder<ToursCubit, LoadState<List<Tour>>>(
      builder: (context, state) {
        final cubit = context.read<ToursCubit>();
        return AppPage(
          title: TourStrings.title,
          subtitle: state.hasData ? TourStrings.toursCount(state.data!.length) : null,
          // Chưa có tour thì nút thêm nằm ngay trong trạng thái rỗng.
          floatingActionButton: !canEdit || (state.data?.isEmpty ?? true)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(TourStrings.addTour),
                ),
          body: LoadStateView<List<Tour>>(
            state: state,
            onRetry: cubit.load,
            isEmpty: (tours) => tours.isEmpty,
            empty: AppEmptyView(
              icon: Icons.tour_outlined,
              title: TourStrings.empty,
              message: canEdit ? TourStrings.emptyHint : null,
              addLabel: TourStrings.addTour,
              onAdd: canEdit ? () => _openForm(context) : null,
            ),
            builder: (context, tours) => RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, AppSpacing.bottomBarClearance),
                children: [
                  if (!canEdit) ...[
                    const NoticeBanner(text: TourStrings.readOnlyNotice, icon: Icons.visibility_outlined),
                    const Gap(AppSpacing.sm),
                  ],
                  for (final tour in tours) ...[
                    TourCard(
                      tour: tour,
                      onTap: canEdit ? () => _openForm(context, tour: tour) : null,
                      trailing: canEdit
                          ? PopupMenuButton<_TourMenu>(
                              icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkTertiary),
                              onSelected: (action) => switch (action) {
                                _TourMenu.edit => _openForm(context, tour: tour),
                                _TourMenu.toggle => _toggle(context, tour),
                                _TourMenu.delete => _delete(context, tour),
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: _TourMenu.edit, child: Text(AppStrings.edit)),
                                PopupMenuItem(
                                  value: _TourMenu.toggle,
                                  child: Text(tour.available ? TourStrings.markPaused : TourStrings.markRunning),
                                ),
                                PopupMenuItem(
                                  value: _TourMenu.delete,
                                  child: Text(
                                    AppStrings.delete,
                                    style: AppTextStyles.body.colored(AppColors.danger),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                    const Gap(AppSpacing.xs),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
