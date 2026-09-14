import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../amenity/domain/entities/amenity.dart';
import '../../../room/domain/entities/room.dart';
import '../../../service/domain/entities/hotel_service.dart';

/// Một cơ sở (entity `Hotel` phía BE — là chi nhánh, không phải chuỗi).
class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.description = '',
    this.category = '',
    this.rating = 0,
    this.pathImage,
    this.active = true,
    this.status,
    this.accountId,
    this.hotelChainId,
    this.amenities = const [],
    this.services = const [],
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String category;
  final int rating;
  final String? pathImage;
  final bool active;

  /// Chỉ có khi tìm theo ngày (`/hotels/search`).
  final HotelStatus? status;

  /// Tài khoản quản lý cơ sở.
  final String? accountId;
  final int? hotelChainId;
  final List<Amenity> amenities;
  final List<HotelService> services;

  bool get acceptsBooking =>
      active && status != HotelStatus.full && status != HotelStatus.inactive;

  Hotel copyWith({bool? active, HotelStatus? status, String? pathImage}) => Hotel(
        id: id,
        name: name,
        address: address,
        phone: phone,
        description: description,
        category: category,
        rating: rating,
        pathImage: pathImage ?? this.pathImage,
        active: active ?? this.active,
        status: status ?? this.status,
        accountId: accountId,
        hotelChainId: hotelChainId,
        amenities: amenities,
        services: services,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        description,
        category,
        rating,
        pathImage,
        active,
        status,
        accountId,
        hotelChainId,
        amenities,
        services,
      ];
}

/// Chi tiết cơ sở (`/hotels/detail/{id}`): ảnh, phòng, mọi tiện ích, dịch vụ.
class HotelDetail extends Equatable {
  const HotelDetail({
    required this.hotel,
    this.images = const [],
    this.rooms = const [],
  });

  final Hotel hotel;
  final List<String> images;
  final List<Room> rooms;

  int get id => hotel.id;

  /// `amenities` của chi tiết gồm cả tiện ích riêng từng phòng; khách chỉ cần chung.
  List<Amenity> get commonAmenities =>
      hotel.amenities.where((a) => a.common).toList();

  List<String> get gallery {
    final cover = hotel.pathImage;
    return [
      if (cover != null && cover.isNotEmpty && !images.contains(cover)) cover,
      ...images,
    ];
  }

  List<Room> get availableRooms =>
      rooms.where((room) => room.status == RoomStatus.available).toList();

  @override
  List<Object?> get props => [hotel, images, rooms];
}
