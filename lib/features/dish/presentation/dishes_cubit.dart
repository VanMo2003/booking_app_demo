import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../domain/entities/dish.dart';
import '../domain/usecases/dish_usecases.dart';

/// Thực đơn một cơ sở — dùng chung cho màn quản lý và màn khách xem.
@injectable
class DishesCubit extends LoadCubit<List<Dish>> {
  DishesCubit(this._getDishes);

  final GetBranchDishes _getDishes;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getDishes(_hotelId));
}
