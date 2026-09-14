import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/text/explore_strings.dart';
import '../../auth/presentation/session/auth_gate.dart';
import '../domain/entities/favorite_hotel.dart';
import 'favorites_cubit.dart';

/// Nút trái tim trên ảnh cơ sở; chưa đăng nhập thì mở cổng đăng nhập trước.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.hotel, this.size = 38});

  final FavoriteHotel hotel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, List<FavoriteHotel>>(
      builder: (context, favorites) {
        final saved = favorites.any((item) => item.id == hotel.id);
        return CircleIconButton(
          size: size,
          icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: saved ? AppColors.danger : AppColors.ink,
          background: AppColors.surface.withValues(alpha: 0.94),
          tooltip: ExploreStrings.tabFavorites,
          onPressed: () async {
            if (!await context.ensureSignedIn()) return;
            if (!context.mounted) return;
            final added = await context.read<FavoritesCubit>().toggle(hotel);
            if (context.mounted) {
              AppToast.info(
                context,
                added ? ExploreStrings.favoriteAdded : ExploreStrings.favoriteRemoved,
              );
            }
          },
        );
      },
    );
  }
}
