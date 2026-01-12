import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';

class Room {
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
  List<String>? images; // optional image URLs
  List<Amenity>? amenities;

  Room({
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

  Room.fromJson(Map<String, dynamic> json) {
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
    // amenities are populated via RoomResponse.toEntity
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['roomNumber'] = roomNumber;
    data['price'] = price;
    data['description'] = description;
    data['capacity'] = capacity;
    data['status'] = status;
    data['hotelId'] = hotelId;
    data['hotelName'] = hotelName;
    data['roomTypeId'] = roomTypeId;
    data['roomTypeName'] = roomTypeName;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    if (images != null) data['images'] = images;
    return data;
  }
}
