import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../hotel/data/models/hotel_models.dart';
import '../../domain/entities/hotel_chain.dart';

/// JSON `ListHotelChainResponse` / `HotelChainDetailResponse` ↔ entity.
abstract final class HotelChainModel {
  static HotelChain fromJson(Json json) => HotelChain(
        id: json.integer('id'),
        name: json.str('name'),
        description: json.str('description'),
        pathImage: json.strOrNull('pathImage'),
        accountId: json.strOrNull('accountId'),
        ownerUsername: json.strOrNull('ownerUsername'),
        ownerName: json.str('ownerName'),
        email: json.str('email'),
        phone: json.str('phone'),
        address: json.str('address'),
        approvalStatus: ApprovalStatus.parse(json.strOrNull('approvalStatus')),
        rejectionReason: json.strOrNull('rejectionReason'),
        submittedAt: json.dateTime('submittedAt'),
        reviewedAt: json.dateTime('reviewedAt'),
      );

  /// Lưu cùng phiên trên máy — dùng lại khoá của BE để đọc bằng [fromJson].
  static Json toJson(HotelChain chain) => {
        'id': chain.id,
        'name': chain.name,
        'description': chain.description,
        'pathImage': chain.pathImage,
        'accountId': chain.accountId,
        'ownerUsername': chain.ownerUsername,
        'ownerName': chain.ownerName,
        'email': chain.email,
        'phone': chain.phone,
        'address': chain.address,
        'approvalStatus': chain.approvalStatus.value,
        'rejectionReason': chain.rejectionReason,
        'submittedAt': chain.submittedAt?.toIso8601String(),
        'reviewedAt': chain.reviewedAt?.toIso8601String(),
      };

  static HotelChainDetail detailFromJson(Json json) => HotelChainDetail(
        chain: fromJson(json),
        hotels: json.listOf('hotels', HotelModel.fromJson),
      );
}

/// Thông tin khách sạn và người đại diện mà quản trị viên xét duyệt — nhập khi
/// đăng ký chủ khách sạn, khi gửi lại hồ sơ và khi tạo chuỗi mới.
class HotelChainProfile {
  const HotelChainProfile({
    required this.hotelName,
    required this.address,
    required this.phone,
    required this.email,
    required this.ownerName,
    this.description = '',
  });

  final String hotelName;
  final String address;
  final String phone;
  final String email;
  final String ownerName;
  final String description;

  /// Khoá của `/owner-registrations` (đăng ký, gửi lại hồ sơ).
  Json toJson() => {
        'hotelName': hotelName.trim(),
        'address': address.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'ownerName': ownerName.trim(),
        'description': description.trim(),
      };
}

class HotelChainRequest {
  const HotelChainRequest({
    required this.name,
    this.description = '',
    this.pathImage,
    this.accountId,
    this.ownerName,
    this.email,
    this.phone,
    this.address,
  });

  factory HotelChainRequest.fromProfile(
    HotelChainProfile profile, {
    required String accountId,
  }) =>
      HotelChainRequest(
        name: profile.hotelName.trim(),
        description: profile.description.trim(),
        accountId: accountId,
        ownerName: profile.ownerName.trim(),
        email: profile.email.trim(),
        phone: profile.phone.trim(),
        address: profile.address.trim(),
      );

  final String name;
  final String description;
  final String? pathImage;

  /// Chỉ gửi khi tạo mới.
  final String? accountId;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String? address;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'pathImage': pathImage ?? '',
        if (accountId != null) 'accountId': accountId,
        if (ownerName != null) 'ownerName': ownerName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };
}
