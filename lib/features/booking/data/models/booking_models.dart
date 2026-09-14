import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';

/// JSON `BookingResponse` / `ListBookingResponse` ↔ [Booking].
abstract final class BookingModel {
  static Booking fromJson(Json json) {
    final hotel = json.obj('hotel');
    final customer = json.obj('customer');
    return Booking(
      id: json.integer('id'),
      checkinDate: json.date('checkinDate') ?? DateOnly.today(),
      checkoutDate: json.date('checkoutDate') ?? DateOnly.today(),
      status: BookingStatus.parse(json.strOrNull('bookingStatus')),
      paymentMethod: PaymentMethod.parse(json.strOrNull('paymentMethod')),
      paymentStatus: PaymentStatus.parse(json.strOrNull('paymentStatus')),
      totalAmount: json.decimal('totalAmount'),
      paymentExpireAt: json.dateTime('paymentExpireAt'),
      paidAt: json.dateTime('paidAt'),
      hotel: hotel == null
          ? null
          : BookingHotel(
              id: hotel.integer('id'),
              name: hotel.str('name'),
              address: hotel.str('address'),
              phone: hotel.str('phone'),
              category: hotel.str('category'),
              rating: hotel.integer('rating'),
              pathImage: hotel.strOrNull('pathImage'),
            ),
      customer: customer == null
          ? null
          : BookingCustomer(
              id: customer.integer('id'),
              fullName: customer.str('fullName'),
              phoneNumber: customer.str('phoneNumber'),
              pathImage: customer.strOrNull('pathImage'),
              gender: customer.str('gender'),
              hometown: customer.str('hometown'),
            ),
      rooms: json
          .listOf('bookingRooms', (item) => item.obj('roomInfo'))
          .whereType<Json>()
          .map(
            (room) => BookedRoom(
              roomId: room.integer('id'),
              roomNumber: room.str('roomNumber'),
              capacity: room.integer('capacity'),
              roomTypeName: room.str('roomTypeName'),
              pathImage: room.strOrNull('pathImage'),
            ),
          )
          .toList(),
      services: json
          .listOf('bookingServices', (item) => item.obj('serviceInfo'))
          .whereType<Json>()
          .map(
            (service) => BookedService(
              serviceId: service.integer('id'),
              name: service.str('name'),
            ),
          )
          .toList(),
      note: json.strOrNull('note'),
      handledByAccountId: json.strOrNull('handledByAccountId'),
      createdAt: json.dateTime('onCreate'),
    );
  }
}

class BookingCreateRequest {
  const BookingCreateRequest({
    required this.checkinDate,
    required this.checkoutDate,
    required this.paymentMethod,
    required this.hotelId,
    required this.customerId,
    required this.roomIds,
    required this.serviceIds,
    required this.totalAmount,
    this.note,
  });

  final DateTime checkinDate;
  final DateTime checkoutDate;
  final PaymentMethod paymentMethod;
  final int hotelId;
  final int customerId;
  final List<int> roomIds;
  final List<int> serviceIds;
  final double totalAmount;
  final String? note;

  Map<String, dynamic> toJson() => {
        'checkinDate': Fmt.apiDate(checkinDate),
        'checkoutDate': Fmt.apiDate(checkoutDate),
        'paymentMethod': paymentMethod.value,
        'hotelId': hotelId,
        'customerId': customerId,
        'rooms': roomIds,
        // BE bắt buộc có mảng này, kể cả khi rỗng.
        'services': serviceIds,
        'totalAmount': totalAmount.round(),
        'note': note ?? '',
      };
}

class BookingUpdateRequest {
  const BookingUpdateRequest({
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
    required this.paymentMethod,
    required this.hotelId,
    required this.customerId,
    required this.roomIds,
    required this.serviceIds,
    required this.totalAmount,
    this.note,
  });

  final DateTime checkinDate;
  final DateTime checkoutDate;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final int hotelId;
  final int customerId;
  final List<int> roomIds;
  final List<int> serviceIds;
  final double totalAmount;
  final String? note;

  /// Tên trường khác lúc tạo: `bookingRooms`, `bookingServices`.
  Map<String, dynamic> toJson() => {
        'checkinDate': Fmt.apiDate(checkinDate),
        'checkoutDate': Fmt.apiDate(checkoutDate),
        'bookingStatus': status.value,
        'paymentMethod': paymentMethod.value,
        'hotelId': hotelId,
        'customerId': customerId,
        'bookingRooms': roomIds,
        'bookingServices': serviceIds,
        'totalAmount': totalAmount.round(),
        'note': note ?? '',
      };
}
