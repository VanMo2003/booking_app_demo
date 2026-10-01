import '../../../../core/network/json_reader.dart';
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
      );
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
        if (hotelId != null) 'hotelId': hotelId,
      };
}
