import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../hotel/domain/entities/hotel.dart';

/// Chuỗi khách sạn — thuộc đúng một tài khoản chủ khách sạn. Kiêm hồ sơ đăng
/// ký đối tác: thông tin liên hệ và trạng thái xét duyệt của quản trị viên.
class HotelChain extends Equatable {
  const HotelChain({
    required this.id,
    required this.name,
    this.description = '',
    this.pathImage,
    this.accountId,
    this.ownerUsername,
    this.ownerName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.approvalStatus = ApprovalStatus.approved,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  final int id;
  final String name;
  final String description;
  final String? pathImage;
  final String? accountId;
  final String? ownerUsername;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final ApprovalStatus approvalStatus;

  /// Lý do lần từ chối gần nhất — vẫn còn sau khi chủ khách sạn gửi lại hồ sơ.
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  bool get isApproved => approvalStatus == ApprovalStatus.approved;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pathImage,
        accountId,
        ownerUsername,
        ownerName,
        email,
        phone,
        address,
        approvalStatus,
        rejectionReason,
        submittedAt,
        reviewedAt,
      ];
}

class HotelChainDetail extends Equatable {
  const HotelChainDetail({required this.chain, this.hotels = const []});

  final HotelChain chain;
  final List<Hotel> hotels;

  int get activeCount => hotels.where((h) => h.active).length;

  /// Tài khoản quản lý đang giữ ít nhất một cơ sở.
  Set<String> get managerAccountIds =>
      hotels.map((h) => h.accountId).whereType<String>().toSet();

  @override
  List<Object?> get props => [chain, hotels];
}
