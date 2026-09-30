import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/text/menu_strings.dart';
import '../domain/entities/dish.dart';
import 'dishes_cubit.dart';
import 'widgets/dish_menu_list.dart';
import 'widgets/dish_tile.dart';

/// Thực đơn đầy đủ của cơ sở, phía khách — công khai, không cần đăng nhập.
@RoutePage()
class HotelMenuScreen extends StatelessWidget {
  const HotelMenuScreen({super.key, required this.hotelId, this.hotelName});

  final int hotelId;
  final String? hotelName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DishesCubit>()..start(hotelId),
      child: BlocBuilder<DishesCubit, LoadState<List<Dish>>>(
        builder: (context, state) {
          final cubit = context.read<DishesCubit>();
          return AppPage(
            title: MenuStrings.title,
            subtitle: hotelName ?? MenuStrings.menuSubtitle,
            body: LoadStateView<List<Dish>>(
              state: state,
              onRetry: cubit.load,
              isEmpty: (dishes) => dishes.isEmpty,
              empty: const AppEmptyView(
                icon: Icons.restaurant_menu_rounded,
                title: MenuStrings.guestEmpty,
              ),
              builder: (context, dishes) => DishMenuList(
                dishes: dishes,
                onRefresh: cubit.load,
                itemBuilder: (context, dish) => DishTile(dish: dish),
              ),
            ),
          );
        },
      ),
    );
  }
}
