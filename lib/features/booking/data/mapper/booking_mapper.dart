import '../../domain/entity/booking_entity.dart';
import '../models/request/booking_create_request.dart';
import '../models/response/booking_response.dart';

class BookingMapper {
  BookingMapper._();

  /* =======================
   * Response -> Entity
   * ======================= */
  static BookingEntity toEntity(BookingResponse dto) {
    return BookingEntity(
      id: dto.id ?? 0,
      checkinDate: dto.checkinDate ?? '',
      checkoutDate: dto.checkoutDate ?? '',
      bookingStatus: dto.bookingStatus ?? '',
      paymentMethod: dto.paymentMethod ?? '',
      hotel: dto.hotel != null ? _hotelToEntity(dto.hotel!) : null,
      customer: dto.customer != null ? _customerToEntity(dto.customer!) : null,
      bookingRooms:
          dto.bookingRooms?.map((e) => _bookingRoomToEntity(e)).toList(),
      bookingServices:
          dto.bookingServices?.map((e) => _bookingServiceToEntity(e)).toList(),
      totalAmount: dto.totalAmount ?? 0,
      note: dto.note ?? '',
      onCreate: dto.onCreate ?? '',
      onUpdate: dto.onUpdate ?? '',
    );
  }

  /* =======================
   * Entity -> Create Request
   * ======================= */
  static BookingCreateRequest toCreateRequest(
    BookingEntity entity, {
    required int hotelId,
    required int customerId,
  }) {
    return BookingCreateRequest(
      checkinDate: entity.checkinDate,
      checkoutDate: entity.checkoutDate,
      paymentMethod: entity.paymentMethod,
      hotelId: hotelId,
      customerId: customerId,
      rooms: entity.bookingRooms
          ?.map((e) => e.roomInfo?.id ?? 0)
          .where((id) => id != 0)
          .toList(),
      services: entity.bookingServices
          ?.map((e) => e.serviceInfo?.id ?? 0)
          .where((id) => id != 0)
          .toList(),
      totalAmount: entity.totalAmount,
      note: entity.note,
    );
  }

  /* =======================
   * Entity -> Response (optional)
   * ======================= */
  static BookingResponse toResponse(BookingEntity entity) {
    return BookingResponse(
      id: entity.id,
      checkinDate: entity.checkinDate,
      checkoutDate: entity.checkoutDate,
      bookingStatus: entity.bookingStatus,
      paymentMethod: entity.paymentMethod,
      hotel: entity.hotel != null ? _hotelToResponse(entity.hotel!) : null,
      customer: entity.customer != null
          ? _customerToResponse(entity.customer!)
          : null,
      bookingRooms:
          entity.bookingRooms?.map((e) => _bookingRoomToResponse(e)).toList(),
      bookingServices: entity.bookingServices
          ?.map((e) => _bookingServiceToResponse(e))
          .toList(),
      totalAmount: entity.totalAmount,
      note: entity.note,
      onCreate: entity.onCreate,
      onUpdate: entity.onUpdate,
    );
  }

  /* =======================
   * Private Mappers
   * ======================= */

  static HotelInfoEntity _hotelToEntity(HotelInfo dto) => HotelInfoEntity(
        id: dto.id ?? 0,
        name: dto.name ?? '',
        address: dto.address ?? '',
        phone: dto.phone ?? '',
        description: dto.description ?? '',
        category: dto.category ?? '',
        rating: dto.rating ?? 0,
        pathImage: dto.pathImage ?? '',
        active: dto.active ?? false,
      );

  static HotelInfo _hotelToResponse(HotelInfoEntity entity) => HotelInfo(
        id: entity.id,
        name: entity.name,
        address: entity.address,
        phone: entity.phone,
        description: entity.description,
        category: entity.category,
        rating: entity.rating,
        pathImage: entity.pathImage,
        active: entity.active,
      );

  static CustomerInfoEntity _customerToEntity(CustomerInfo dto) =>
      CustomerInfoEntity(
        id: dto.id ?? 0,
        pathImage: dto.pathImage ?? '',
        fullName: dto.fullName ?? '',
        phoneNumber: dto.phoneNumber ?? '',
        gender: dto.gender ?? '',
        hometown: dto.hometown ?? '',
      );

  static CustomerInfo _customerToResponse(CustomerInfoEntity entity) =>
      CustomerInfo(
        id: entity.id,
        pathImage: entity.pathImage,
        fullName: entity.fullName,
        phoneNumber: entity.phoneNumber,
        gender: entity.gender,
        hometown: entity.hometown,
      );

  static BookingRoomsEntity _bookingRoomToEntity(BookingRooms dto) =>
      BookingRoomsEntity(
        id: dto.id ?? 0,
        roomInfo:
            dto.roomInfo != null ? _roomInfoToEntity(dto.roomInfo!) : null,
      );

  static BookingRooms _bookingRoomToResponse(BookingRoomsEntity entity) =>
      BookingRooms(
        id: entity.id,
        roomInfo: entity.roomInfo != null
            ? _roomInfoToResponse(entity.roomInfo!)
            : null,
      );

  static RoomInfoEntity _roomInfoToEntity(RoomInfo dto) => RoomInfoEntity(
        id: dto.id ?? 0,
        pathImage: dto.pathImage ?? '',
        roomNumber: dto.roomNumber ?? '',
        capacity: dto.capacity ?? 0,
        roomTypeName: dto.roomTypeName ?? '',
      );

  static RoomInfo _roomInfoToResponse(RoomInfoEntity entity) => RoomInfo(
        id: entity.id,
        pathImage: entity.pathImage,
        roomNumber: entity.roomNumber,
        capacity: entity.capacity,
        roomTypeName: entity.roomTypeName,
      );

  static BookingServicesEntity _bookingServiceToEntity(BookingServices dto) =>
      BookingServicesEntity(
        id: dto.id ?? 0,
        serviceInfo: dto.serviceInfo != null
            ? _serviceInfoToEntity(dto.serviceInfo!)
            : null,
      );

  static BookingServices _bookingServiceToResponse(
          BookingServicesEntity entity) =>
      BookingServices(
        id: entity.id,
        serviceInfo: entity.serviceInfo != null
            ? _serviceInfoToResponse(entity.serviceInfo!)
            : null,
      );

  static ServiceInfoEntity _serviceInfoToEntity(ServiceInfo dto) =>
      ServiceInfoEntity(
        id: dto.id ?? 0,
        name: dto.name ?? '',
      );

  static ServiceInfo _serviceInfoToResponse(ServiceInfoEntity entity) =>
      ServiceInfo(
        id: entity.id,
        name: entity.name,
      );
}
