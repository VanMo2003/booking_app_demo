import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/paged.dart';
import '../../../hotel_chain/data/models/hotel_chain_models.dart';
import '../../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../data/models/partner_models.dart';

/// Hồ sơ đăng ký chủ khách sạn — chính là [HotelChain] kèm trạng thái duyệt.
abstract interface class PartnerRepository {
  Future<HotelChain> register(OwnerRegistrationRequest request);

  Future<HotelChain> myRegistration();

  Future<HotelChain> resubmit(HotelChainProfile profile);

  Future<Paged<HotelChain>> registrations({
    ApprovalStatus? status,
    required int page,
    required int size,
  });

  Future<HotelChain> registration(int id);

  Future<HotelChain> approve(int id);

  Future<HotelChain> reject(int id, String reason);
}
