import 'package:equatable/equatable.dart';

enum DiscountType {
  percent('PERCENT'),
  amount('AMOUNT');

  const DiscountType(this.value);

  final String value;

  static DiscountType parse(String? raw) => raw == 'AMOUNT' ? amount : percent;
}

/// Mã giảm giá của một chuỗi cho đơn tour, dùng ở mọi cơ sở của chuỗi hoặc một cơ sở.
class Voucher extends Equatable {
  const Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.value,
    required this.startsAt,
    required this.endsAt,
    this.description,
    this.maxDiscount,
    this.minOrderAmount,
    this.usageLimit,
    this.usedCount = 0,
    this.perCustomerLimit = 1,
    this.active = true,
    this.hotelChainId,
    this.hotelChainName,
    this.hotelId,
    this.hotelName,
  });

  final int id;
  final String code;
  final String title;
  final String? description;
  final DiscountType discountType;

  /// Phần trăm (1–90) hoặc số tiền.
  final double value;
  final double? maxDiscount;
  final double? minOrderAmount;
  final DateTime startsAt;
  final DateTime endsAt;

  /// `null` = không giới hạn.
  final int? usageLimit;
  final int usedCount;
  final int perCustomerLimit;
  final bool active;
  final int? hotelChainId;
  final String? hotelChainName;

  /// `null` = mọi cơ sở của chuỗi.
  final int? hotelId;
  final String? hotelName;

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        discountType,
        value,
        maxDiscount,
        minOrderAmount,
        startsAt,
        endsAt,
        usageLimit,
        usedCount,
        perCustomerLimit,
        active,
        hotelChainId,
        hotelChainName,
        hotelId,
        hotelName,
      ];
}

/// Kết quả thử mã cho một đơn: hợp lệ thì giảm bao nhiêu; không thì [message] nói vì sao.
class VoucherCheck extends Equatable {
  const VoucherCheck({
    required this.valid,
    required this.message,
    required this.code,
    required this.tourAmount,
    required this.discount,
    required this.finalAmount,
  });

  final bool valid;
  final String message;
  final String code;
  final double tourAmount;
  final double discount;
  final double finalAmount;

  @override
  List<Object?> get props => [valid, message, code, tourAmount, discount, finalAmount];
}

/// Tạo hoặc sửa mã (khi sửa: `null` = giữ nguyên).
class VoucherRequest {
  const VoucherRequest({
    this.code,
    this.title,
    this.description,
    this.discountType,
    this.value,
    this.maxDiscount,
    this.minOrderAmount,
    this.startsAt,
    this.endsAt,
    this.usageLimit,
    this.perCustomerLimit,
    this.active,
    this.hotelChainId,
    this.hotelId,
  });

  final String? code;
  final String? title;
  final String? description;
  final DiscountType? discountType;
  final double? value;

  /// 0 = bỏ giới hạn / bỏ điều kiện.
  final double? maxDiscount;
  final double? minOrderAmount;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// 0 = không giới hạn.
  final int? usageLimit;
  final int? perCustomerLimit;
  final bool? active;
  final int? hotelChainId;
  final int? hotelId;
}
