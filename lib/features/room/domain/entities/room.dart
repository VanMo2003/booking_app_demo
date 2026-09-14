import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../amenity/domain/entities/amenity.dart';

class Room extends Equatable {
  const Room({
    required this.id,
    required this.roomNumber,
    required this.price,
    this.pathImage,
    this.description = '',
    this.capacity = 1,
    this.status = RoomStatus.available,
    this.hotelId,
    this.hotelName,
    this.roomTypeId,
    this.roomTypeName = '',
  });

  final int id;
  final String roomNumber;
  final double price;
  final String? pathImage;
  final String description;
  final int capacity;

  /// Khi gọi kèm ngày, BE tính lại: AVAILABLE/BOOKED; MAINTENANCE/OCCUPIED giữ nguyên.
  final RoomStatus status;
  final int? hotelId;
  final String? hotelName;
  final int? roomTypeId;
  final String roomTypeName;

  String get title =>
      roomTypeName.isEmpty ? 'Phòng $roomNumber' : 'Phòng $roomNumber · $roomTypeName';

  @override
  List<Object?> get props => [
        id,
        roomNumber,
        price,
        pathImage,
        description,
        capacity,
        status,
        hotelId,
        hotelName,
        roomTypeId,
        roomTypeName,
      ];
}

class RoomDetail extends Equatable {
  const RoomDetail({
    required this.room,
    this.images = const [],
    this.amenities = const [],
  });

  final Room room;
  final List<String> images;
  final List<Amenity> amenities;

  List<String> get gallery {
    final cover = room.pathImage;
    return [
      if (cover != null && cover.isNotEmpty && !images.contains(cover)) cover,
      ...images,
    ];
  }

  @override
  List<Object?> get props => [room, images, amenities];
}
