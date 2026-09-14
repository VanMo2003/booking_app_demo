import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/hotel_usecases.dart';

/// Chi tiết một cơ sở: tên trên đầu các tab làm việc, tiện ích, thông tin cơ sở.
@injectable
class BranchCubit extends LoadCubit<HotelDetail> {
  BranchCubit(this._getDetail);

  final GetHotelDetail _getDetail;
  late int _hotelId;

  Future<void> loadBranch(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getDetail(_hotelId));
}
