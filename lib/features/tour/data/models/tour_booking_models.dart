import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour_booking.dart';
import 'tour_models.dart';

/// JSON `TourBookingResponse` ↔ [TourBooking].
abstract final class TourBookingModel {
  static TourBooking fromJson(Json json) => TourBooking(
        id: json.integer('id'),
        tourId: json.intOrNull('tourId'),
        tourName: json.str('tourName'),
        tourPathImage: json.strOrNull('tourPathImage'),
        tourDuration: json.strOrNull('tourDuration'),
        tourDeparture: json.strOrNull('tourDeparture'),
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        hotelPhone: json.str('hotelPhone'),
        customerName: json.str('customerName'),
        customerPhone: json.str('customerPhone'),
        conversationId: json.intOrNull('conversationId'),
        tourDate: json.date('tourDate') ?? DateOnly.today(),
        guests: json.integer('guests', 1),
        unitPrice: json.decimal('unitPrice'),
        totalAmount: json.decimal('totalAmount'),
        status: TourBookingStatus.parse(json.strOrNull('status')),
        note: json.strOrNull('note'),
        cancelReason: json.strOrNull('cancelReason'),
        canceledByGuest: json.strOrNull('canceledBy') == 'CUSTOMER',
        createdByAi: json.flag('createdByAi'),
        createdAt: json.dateTime('onCreate'),
        tourAmount: json['tourAmount'] == null ? null : json.decimal('tourAmount'),
        roomAmount: json.decimal('roomAmount'),
        bookingId: json.intOrNull('bookingId'),
        stayCheckout: json.date('stayCheckout'),
        rooms: TourRoomModel.listFrom(json, 'rooms'),
      );
}

/// Khách đặt tour trong ứng dụng.
class TourBookingRequest {
  const TourBookingRequest({
    required this.tourId,
    required this.tourDate,
    required this.guests,
    this.roomIds = const [],
    this.note = '',
  });

  final int tourId;
  final DateTime tourDate;
  final int guests;
  final List<int> roomIds;
  final String note;

  Map<String, dynamic> toJson() => {
        'tourId': tourId,
        'tourDate': Fmt.apiDate(tourDate),
        'guests': guests,
        if (roomIds.isNotEmpty) 'roomIds': roomIds,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      };
}
