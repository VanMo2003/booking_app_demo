import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../domain/entities/hotel_chain.dart';
import '../../domain/repositories/hotel_chain_repository.dart';
import '../datasources/hotel_chain_api.dart';
import '../models/hotel_chain_models.dart';

@LazySingleton(as: HotelChainRepository)
class HotelChainRepositoryImpl implements HotelChainRepository {
  HotelChainRepositoryImpl(this._api);

  final HotelChainApi _api;

  @override
  Future<HotelChain> create(HotelChainRequest request) async =>
      (await _api.create(request.toJson())).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChain> update(int id, HotelChainRequest request) async =>
      (await _api.update(id, request.toJson())).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChainDetail> getDetail(int id) async =>
      (await _api.getById(id)).parse(HotelChainModel.detailFromJson);

  @override
  Future<Paged<HotelChain>> getAll({required int page, required int size}) async =>
      (await _api.getAll(page, size)).parsePage(HotelChainModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
