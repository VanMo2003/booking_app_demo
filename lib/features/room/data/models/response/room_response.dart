import '../../../domain/entity/room.dart';

class RoomResponse {
  int? id;
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

  RoomResponse({
    this.id,
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
  });

  RoomResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
  }

  Room toEntity() => Room(
        id: id,
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
      );
}
