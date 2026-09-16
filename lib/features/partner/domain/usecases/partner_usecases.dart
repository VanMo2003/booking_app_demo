import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/paged.dart';
import '../../../auth/domain/entities/session.dart';
import '../../../hotel_chain/data/models/hotel_chain_models.dart';
import '../../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../data/models/partner_models.dart';
import '../repositories/partner_repository.dart';

/// Tạo tài khoản chủ khách sạn kèm hồ sơ chờ duyệt. Việc đăng nhập tách riêng
/// (`Login`) để báo đúng lỗi khi hồ sơ đã gửi mà đăng nhập thất bại.
@injectable
class RegisterOwner {
  const RegisterOwner(this._repository);

  final PartnerRepository _repository;

  Future<HotelChain> call({
    required String username,
    required String password,
    required HotelChainProfile profile,
  }) =>
      _repository.register(
        OwnerRegistrationRequest(username: username, password: password, profile: profile),
      );
}

/// Hỏi lại máy chủ trạng thái duyệt và gắn vào phiên.
@injectable
class RefreshOwnerStatus {
  const RefreshOwnerStatus(this._repository);

  final PartnerRepository _repository;

  Future<Session> call(Session session) async =>
      session.copyWith(hotelChain: await _repository.myRegistration());
}

/// Sửa hồ sơ đang chờ duyệt, hoặc gửi lại sau khi bị từ chối.
@injectable
class ResubmitOwnerProfile {
  const ResubmitOwnerProfile(this._repository);

  final PartnerRepository _repository;

  Future<HotelChain> call(HotelChainProfile profile) => _repository.resubmit(profile);
}

@injectable
class GetOwnerRegistrations {
  const GetOwnerRegistrations(this._repository);

  final PartnerRepository _repository;

  Future<Paged<HotelChain>> call({
    required ApprovalStatus status,
    required int page,
    required int size,
  }) =>
      _repository.registrations(status: status, page: page, size: size);
}

@injectable
class GetOwnerRegistration {
  const GetOwnerRegistration(this._repository);

  final PartnerRepository _repository;

  Future<HotelChain> call(int id) => _repository.registration(id);
}

@injectable
class ApproveOwner {
  const ApproveOwner(this._repository);

  final PartnerRepository _repository;

  Future<HotelChain> call(int id) => _repository.approve(id);
}

@injectable
class RejectOwner {
  const RejectOwner(this._repository);

  final PartnerRepository _repository;

  Future<HotelChain> call(int id, String reason) => _repository.reject(id, reason);
}

/// Số hồ sơ đang chờ duyệt (đọc `totalElements` của trang đầu).
@injectable
class CountPendingOwners {
  const CountPendingOwners(this._repository);

  final PartnerRepository _repository;

  Future<int> call() async => (await _repository.registrations(
        status: ApprovalStatus.pending,
        page: 0,
        size: 1,
      ))
          .totalElements;
}
