import 'package:equatable/equatable.dart';

/// Tour tham quan cơ sở tổ chức, bán theo gói kèm phòng: khách sạn gắn các phòng của gói và số đêm ở
/// (nhận phòng đúng ngày đi tour); khách chọn một trong các phòng còn trống. Tour không gắn phòng thì
/// chỉ đặt tour. Giá tour tính mỗi khách, tiền phòng tính theo đêm.
class Tour extends Equatable {
  const Tour({
    required this.id,
    required this.name,
    required this.price,
    required this.hotelId,
    this.description = '',
    this.duration,
    this.departure,
    this.includes,
    this.maxGuests,
    this.pathImage,
    this.available = true,
    this.stayNights = 1,
    this.rooms = const [],
  });

  final int id;
  final String name;
  final double price;
  final int hotelId;
  final String description;
  final String? duration;
  final String? departure;
  final String? includes;
  final int? maxGuests;
  final String? pathImage;

  /// `false` = tạm ngừng; tour vẫn hiện, mờ đi.
  final bool available;

  /// Số đêm ở kèm tour, tính từ ngày đi tour.
  final int stayNights;

  /// Phòng của gói, rẻ trước; rỗng = tour không kèm phòng.
  final List<TourRoom> rooms;

  bool get withRooms => rooms.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        hotelId,
        description,
        duration,
        departure,
        includes,
        maxGuests,
        pathImage,
        available,
        stayNights,
        rooms,
      ];
}

/// Một phòng của gói tour (hoặc của đơn tour), giá mỗi đêm.
class TourRoom extends Equatable {
  const TourRoom({
    required this.roomId,
    required this.roomNumber,
    required this.price,
    this.roomTypeName = '',
    this.capacity = 0,
    this.pathImage,
  });

  final int roomId;
  final String roomNumber;
  final String roomTypeName;
  final int capacity;
  final double price;
  final String? pathImage;

  @override
  List<Object?> get props => [roomId, roomNumber, roomTypeName, capacity, price, pathImage];
}

/// Kỳ ở bán kèm tour cho một ngày đi: ngày nhận/trả phòng và các phòng của gói còn trống.
class TourStay extends Equatable {
  const TourStay({
    required this.checkin,
    required this.checkout,
    required this.nights,
    required this.withRooms,
    this.rooms = const [],
  });

  final DateTime checkin;
  final DateTime checkout;
  final int nights;
  final bool withRooms;
  final List<TourRoom> rooms;

  @override
  List<Object?> get props => [checkin, checkout, nights, withRooms, rooms];
}
