import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/tour_booking.dart';

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
      );
}
