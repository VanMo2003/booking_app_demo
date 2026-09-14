import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../domain/entities/hotel_chain.dart';
import '../domain/usecases/hotel_chain_usecases.dart';

/// Chi tiết chuỗi (danh sách cơ sở) — dùng chung cho các tab của chủ khách sạn.
@injectable
class ChainCubit extends LoadCubit<HotelChainDetail> {
  ChainCubit(this._getDetail);

  final GetHotelChainDetail _getDetail;
  late int _chainId;

  Future<void> start(int chainId) {
    _chainId = chainId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getDetail(_chainId));
}

@injectable
class ChainOverviewCubit extends LoadCubit<ChainOverview> {
  ChainOverviewCubit(this._loadOverview);

  final LoadChainOverview _loadOverview;
  late int _chainId;

  Future<void> start(int chainId) {
    _chainId = chainId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _loadOverview(_chainId));
}

@injectable
class ManagersCubit extends LoadCubit<List<ManagerSummary>> {
  ManagersCubit(this._getDetail, this._getManagers);

  final GetHotelChainDetail _getDetail;
  final GetChainManagers _getManagers;
  late int _chainId;
  late String _ownerUsername;

  Future<void> start({required int chainId, required String ownerUsername}) {
    _chainId = chainId;
    _ownerUsername = ownerUsername;
    return load();
  }

  @override
  Future<void> load() => guard(() async {
        final detail = await _getDetail(_chainId);
        return _getManagers(detail, ownerUsername: _ownerUsername);
      });
}
