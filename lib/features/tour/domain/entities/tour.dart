import 'package:equatable/equatable.dart';

import 'travel_theme.dart';

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
    this.hotelName,
    this.hotelAddress,
    this.destination,
    this.themes = const [],
    this.itinerary = const [],
    this.childPrice,
    this.cancellationPolicy,
    this.featured = false,
    this.discountPercent,
    this.promotionEndsAt,
    this.onSale = false,
    double? salePrice,
    this.saleChildPrice,
  }) : salePrice = salePrice ?? price;

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

  final String? hotelName;
  final String? hotelAddress;

  /// Nơi tour đi tới: "Hạ Long, Quảng Ninh".
  final String? destination;
  final List<TravelTheme> themes;

  /// Lịch trình theo thứ tự, hiện dạng timeline.
  final List<ItineraryStep> itinerary;

  /// Giá mỗi trẻ em; `null` = như người lớn.
  final double? childPrice;
  final String? cancellationPolicy;
  final bool featured;

  /// Khuyến mãi phần trăm đến hết [promotionEndsAt] (null = đến khi tắt).
  final int? discountPercent;
  final DateTime? promotionEndsAt;

  /// Khuyến mãi đang chạy hôm nay: [salePrice] / [saleChildPrice] là giá khách trả.
  final bool onSale;
  final double salePrice;
  final double? saleChildPrice;

  /// Giá mỗi trẻ em khách trả hôm nay.
  double get childPayPrice => saleChildPrice ?? childPrice ?? salePrice;

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
        hotelName,
        hotelAddress,
        destination,
        themes,
        itinerary,
        childPrice,
        cancellationPolicy,
        featured,
        discountPercent,
        promotionEndsAt,
        onSale,
        salePrice,
        saleChildPrice,
      ];
}

/// Một chặng trong lịch trình tour: "08:00" · "Đón khách tại khách sạn" · mô tả.
class ItineraryStep extends Equatable {
  const ItineraryStep({required this.title, this.time, this.description});

  final String? time;
  final String title;
  final String? description;

  @override
  List<Object?> get props => [time, title, description];
}

/// Một địa điểm du lịch có tour: số tour, giá từ, ảnh một tour ở đó.
class TourDestination extends Equatable {
  const TourDestination({required this.name, required this.tours, required this.fromPrice, this.pathImage});

  final String name;
  final int tours;
  final double fromPrice;
  final String? pathImage;

  @override
  List<Object?> get props => [name, tours, fromPrice, pathImage];
}

/// Trang chủ của khách: tour nổi bật, đang khuyến mãi, gợi ý theo sở thích, địa điểm.
class TourHome extends Equatable {
  const TourHome({
    this.featured = const [],
    this.deals = const [],
    this.forYou = const [],
    this.destinations = const [],
  });

  final List<Tour> featured;
  final List<Tour> deals;
  final List<Tour> forYou;
  final List<TourDestination> destinations;

  @override
  List<Object?> get props => [featured, deals, forYou, destinations];
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
