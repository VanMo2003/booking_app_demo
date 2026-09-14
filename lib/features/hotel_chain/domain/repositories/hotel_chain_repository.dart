import '../../../../core/network/paged.dart';
import '../../data/models/hotel_chain_models.dart';
import '../entities/hotel_chain.dart';

abstract interface class HotelChainRepository {
  Future<HotelChain> create(HotelChainRequest request);

  Future<HotelChain> update(int id, HotelChainRequest request);

  Future<HotelChainDetail> getDetail(int id);

  Future<Paged<HotelChain>> getAll({required int page, required int size});

  Future<void> delete(int id);
}
