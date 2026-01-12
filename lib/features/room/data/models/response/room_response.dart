import 'package:booking_app_mobile/features/amenity/data/mapper/amenity_mapper.dart';
import 'package:booking_app_mobile/features/amenity/data/models/amenity_response.dart';

import '../../../domain/entity/room.dart';

class RoomResponse {
  int? id;
  String? pathImage;
  String? roomNumber;
  int? price;
  String? description;
  int? capacity;
  String? status;
  int? hotelId;
  String? hotelName;
  int? roomTypeId;
  String? roomTypeName;
  String? onCreate;
  String? onUpdate;
  List<String>? images;
  List<AmenityResponse>? amenities;

  RoomResponse({
    this.id,
    this.pathImage,
    this.roomNumber,
    this.price,
    this.description,
    this.capacity,
    this.status,
    this.hotelId,
    this.hotelName,
    this.roomTypeId,
    this.roomTypeName,
    this.onCreate,
    this.onUpdate,
    this.images,
    this.amenities,
  });

  RoomResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    roomNumber = json['roomNumber'];
    price = json['price'];
    description = json['description'];
    capacity = json['capacity'];
    status = json['status'];
    hotelId = json['hotelId'];
    hotelName = json['hotelName'];
    roomTypeId = json['roomTypeId'];
    roomTypeName = json['roomTypeName'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    if (json['amenities'] != null) {
      amenities = <AmenityResponse>[];
      json['amenities'].forEach((v) {
        amenities!.add(AmenityResponse.fromJson(v));
      });
    }
  }

  Room toEntity() => Room(
        id: id,
        pathImage: pathImage,
        roomNumber: roomNumber,
        price: price,
        description: description,
        capacity: capacity,
        status: status,
        hotelId: hotelId,
        hotelName: hotelName,
        roomTypeId: roomTypeId,
        roomTypeName: roomTypeName,
        onCreate: onCreate,
        onUpdate: onUpdate,
        images: images,
        amenities: amenities?.map(AmenityMapper.toEntity).toList(),
      );
}
