import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/paged.dart';
import '../../../hotel_chain/data/models/hotel_chain_models.dart';
import '../../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_api.dart';
import '../models/partner_models.dart';

@LazySingleton(as: PartnerRepository)
class PartnerRepositoryImpl implements PartnerRepository {
  PartnerRepositoryImpl(this._api);

  final PartnerApi _api;

  @override
  Future<HotelChain> register(OwnerRegistrationRequest request) async =>
      (await _api.register(request.toJson())).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChain> myRegistration() async =>
      (await _api.getMine()).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChain> resubmit(HotelChainProfile profile) async =>
      (await _api.resubmit(profile.toJson())).parse(HotelChainModel.fromJson);

  @override
  Future<Paged<HotelChain>> registrations({
    ApprovalStatus? status,
    required int page,
    required int size,
  }) async =>
      (await _api.getAll(status?.value, page, size))
          .parsePage(HotelChainModel.fromJson);

  @override
  Future<HotelChain> registration(int id) async =>
      (await _api.getById(id)).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChain> approve(int id) async =>
      (await _api.approve(id)).parse(HotelChainModel.fromJson);

  @override
  Future<HotelChain> reject(int id, String reason) async =>
      (await _api.reject(id, {'reason': reason.trim()}))
          .parse(HotelChainModel.fromJson);
}
