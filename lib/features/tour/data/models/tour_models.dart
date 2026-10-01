import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour.dart';

/// JSON `TourResponse` ↔ [Tour].
abstract final class TourModel {
  static Tour fromJson(Json json) => Tour(
        id: json.integer('id'),
        name: json.str('name'),
        price: json.decimal('price'),
        hotelId: json.integer('hotelId'),
        description: json.str('description'),
        duration: json.strOrNull('duration'),
        departure: json.strOrNull('departure'),
        includes: json.strOrNull('includes'),
        maxGuests: json.intOrNull('maxGuests'),
        pathImage: json.strOrNull('pathImage'),
        available: json.flag('available', true),
        stayNights: json.integer('stayNights', 1),
        rooms: TourRoomModel.listFrom(json, 'rooms'),
      );
}

abstract final class TourRoomModel {
  static TourRoom fromJson(Json json) => TourRoom(
        roomId: json.integer('roomId'),
        roomNumber: json.str('roomNumber'),
        roomTypeName: json.str('roomTypeName'),
        capacity: json.integer('capacity'),
        price: json.decimal('price'),
        pathImage: json.strOrNull('pathImage'),
      );

  static List<TourRoom> listFrom(Json json, String key) {
    final raw = json[key];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }
}

abstract final class TourStayModel {
  static TourStay fromJson(Json json) => TourStay(
        checkin: json.date('checkin') ?? DateOnly.today(),
        checkout: json.date('checkout') ?? DateOnly.today(),
        nights: json.integer('nights', 1),
        withRooms: json.flag('withRooms'),
        rooms: TourRoomModel.listFrom(json, 'rooms'),
      );

  static String queryDate(DateTime date) => Fmt.apiDate(date);
}

class TourRequest {
  const TourRequest({
    required this.name,
    required this.price,
    this.description = '',
    this.duration = '',
    this.departure = '',
    this.includes = '',
    this.maxGuests,
    this.pathImage,
    this.available = true,
    this.hotelId,
    this.stayNights = 1,
    this.roomIds,
  });

  final String name;
  final double price;

  /// Chuỗi rỗng = xoá nội dung cũ khi sửa.
  final String description;
  final String duration;
  final String departure;
  final String includes;

  /// `null` = không giới hạn.
  final int? maxGuests;

  /// Link dán tay; `''` khi sửa = gỡ ảnh; `null` = giữ nguyên / ảnh chọn từ máy tải lên sau.
  final String? pathImage;
  final bool available;

  /// Chỉ cần khi tạo mới.
  final int? hotelId;

  final int stayNights;

  /// Phòng của gói; `null` = giữ nguyên, rỗng = tour không kèm phòng.
  final List<int>? roomIds;

  bool get _isCreate => hotelId != null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price.round(),
        'description': description,
        'duration': duration,
        'departure': departure,
        'includes': includes,
        // Sửa: 0 = bỏ giới hạn; tạo mới: không gửi là không giới hạn.
        if (maxGuests != null) 'maxGuests': maxGuests else if (!_isCreate) 'maxGuests': 0,
        if (pathImage != null) 'pathImage': pathImage,
        'available': available,
        'stayNights': stayNights,
        if (roomIds != null) 'roomIds': roomIds,
        if (hotelId != null) 'hotelId': hotelId,
      };
}
