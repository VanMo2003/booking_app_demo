import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/menu_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/dish.dart';
import '../domain/usecases/dish_usecases.dart';
import 'dishes_cubit.dart';
import 'widgets/dish_menu_list.dart';
import 'widgets/dish_tile.dart';

/// Thực đơn của cơ sở trong không gian làm việc. Chủ khách sạn và quản lý cơ sở
/// thêm, sửa, xoá món; nhân viên và quản trị viên chỉ xem.
@RoutePage()
class DishesScreen extends StatelessWidget {
  const DishesScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DishesCubit>()..start(hotelId),
      child: _DishesView(hotelId: hotelId),
    );
  }
}

enum _DishMenu { edit, toggle, delete }

class _DishesView extends StatelessWidget {
  const _DishesView({required this.hotelId});

  final int hotelId;

  Future<void> _openForm(BuildContext context, {Dish? dish}) async {
    final saved = await context.router.push<bool>(DishFormRoute(hotelId: hotelId, dish: dish));
    if (saved == true && context.mounted) await context.read<DishesCubit>().load();
  }

  Future<void> _toggle(BuildContext context, Dish dish) async {
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<SetDishAvailable>()(dish.id, !dish.available)),
      successMessage: dish.available ? MenuStrings.markedUnavailable : MenuStrings.markedAvailable,
    );
    if (result.isSuccess && context.mounted) await context.read<DishesCubit>().load();
  }

  Future<void> _delete(BuildContext context, Dish dish) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(dish.name),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteDish>()(dish.id)),
      successMessage: MenuStrings.deleted,
    );
    if (result.isSuccess && context.mounted) await context.read<DishesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select((SessionCubit cubit) => cubit.state.role);
    final canEdit = role?.canManageMenu ?? false;
    return BlocBuilder<DishesCubit, LoadState<List<Dish>>>(
      builder: (context, state) {
        final cubit = context.read<DishesCubit>();
        return AppPage(
          title: MenuStrings.title,
          subtitle: state.hasData ? MenuStrings.dishesCount(state.data!.length) : null,
          // Thực đơn trống thì nút thêm nằm ngay trong trạng thái rỗng.
          floatingActionButton: !canEdit || (state.data?.isEmpty ?? true)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(MenuStrings.addDish),
                ),
          body: LoadStateView<List<Dish>>(
            state: state,
            onRetry: cubit.load,
            isEmpty: (dishes) => dishes.isEmpty,
            empty: AppEmptyView(
              icon: Icons.restaurant_menu_rounded,
              title: MenuStrings.empty,
              message: canEdit ? MenuStrings.emptyHint : null,
              addLabel: MenuStrings.addDish,
              onAdd: canEdit ? () => _openForm(context) : null,
            ),
            builder: (context, dishes) => DishMenuList(
              dishes: dishes,
              onRefresh: cubit.load,
              header: canEdit
                  ? null
                  : const NoticeBanner(
                      text: MenuStrings.readOnlyNotice,
                      icon: Icons.visibility_outlined,
                    ),
              itemBuilder: (context, dish) => DishTile(
                dish: dish,
                onTap: canEdit ? () => _openForm(context, dish: dish) : null,
                trailing: canEdit
                    ? PopupMenuButton<_DishMenu>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkTertiary),
                        onSelected: (action) => switch (action) {
                          _DishMenu.edit => _openForm(context, dish: dish),
                          _DishMenu.toggle => _toggle(context, dish),
                          _DishMenu.delete => _delete(context, dish),
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: _DishMenu.edit, child: Text(AppStrings.edit)),
                          PopupMenuItem(
                            value: _DishMenu.toggle,
                            child: Text(
                              dish.available
                                  ? MenuStrings.markUnavailable
                                  : MenuStrings.markAvailable,
                            ),
                          ),
                          PopupMenuItem(
                            value: _DishMenu.delete,
                            child: Text(
                              AppStrings.delete,
                              style: AppTextStyles.body.colored(AppColors.danger),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
