import 'package:equatable/equatable.dart';

/// Tour tham quan cơ sở tổ chức; giá tính mỗi khách, đặt qua nhân viên khách sạn.
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

  @override
  List<Object?> get props =>
      [id, name, price, hotelId, description, duration, departure, includes, maxGuests, pathImage, available];
}
