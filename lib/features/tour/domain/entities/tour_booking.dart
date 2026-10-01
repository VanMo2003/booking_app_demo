import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

/// Đơn tour của khách. Tên tour và giá được chốt lúc đặt; [tourId] `null` khi tour đã bị gỡ.
class TourBooking extends Equatable {
  const TourBooking({
    required this.id,
    required this.tourName,
    required this.hotelId,
    required this.tourDate,
    required this.guests,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    this.tourId,
    this.tourPathImage,
    this.tourDuration,
    this.tourDeparture,
    this.hotelName = '',
    this.hotelPhone = '',
    this.customerName = '',
    this.customerPhone = '',
    this.conversationId,
    this.note,
    this.cancelReason,
    this.canceledByGuest = false,
    this.createdByAi = false,
    this.createdAt,
  });

  final int id;
  final int? tourId;
  final String tourName;
  final String? tourPathImage;
  final String? tourDuration;
  final String? tourDeparture;
  final int hotelId;
  final String hotelName;
  final String hotelPhone;
  final String customerName;
  final String customerPhone;

  /// Cuộc trò chuyện trợ lý AI đã lên đơn; `null` nếu đặt trong ứng dụng.
  final int? conversationId;
  final DateTime tourDate;
  final int guests;
  final double unitPrice;
  final double totalAmount;
  final TourBookingStatus status;
  final String? note;
  final String? cancelReason;
  final bool canceledByGuest;
  final bool createdByAi;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        tourId,
        tourName,
        tourPathImage,
        tourDuration,
        tourDeparture,
        hotelId,
        hotelName,
        hotelPhone,
        customerName,
        customerPhone,
        conversationId,
        tourDate,
        guests,
        unitPrice,
        totalAmount,
        status,
        note,
        cancelReason,
        canceledByGuest,
        createdByAi,
        createdAt,
      ];
}
