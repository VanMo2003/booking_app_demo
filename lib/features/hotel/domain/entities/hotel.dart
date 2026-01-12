class Hotel {
  int id;
  String name;
  String address;
  String phone;
  String description;
  String category;
  int rating;
  String pathImage;
  List<String> images;
  bool active;
  String accountId;
  List<HotelRoom> rooms;
  List<HotelAmenity> amenities;
  List<HotelService> services;
  String onCreate;
  String onUpdate;

  Hotel(
      {required this.id,
      required this.name,
      required this.address,
      required this.phone,
      required this.description,
      required this.category,
      required this.rating,
      required this.pathImage,
      required this.images,
      required this.active,
      required this.accountId,
      required this.rooms,
      required this.amenities,
      required this.services,
      required this.onCreate,
      required this.onUpdate});
}

class HotelRoom {
  int id;
  String pathImage;
  String roomNumber;
  int price;
  String description;
  int capacity;
  String status;
  int hotelId;
  String hotelName;
  int roomTypeId;
  String roomTypeName;
  String onCreate;
  String onUpdate;

  HotelRoom(
      {required this.id,
      required this.pathImage,
      required this.roomNumber,
      required this.price,
      required this.description,
      required this.capacity,
      required this.status,
      required this.hotelId,
      required this.hotelName,
      required this.roomTypeId,
      required this.roomTypeName,
      required this.onCreate,
      required this.onUpdate});
}

class HotelAmenity {
  int id;
  String name;
  String description;
  bool common;
  bool active;
  String onCreate;
  String onUpdate;

  HotelAmenity(
      {required this.id,
      required this.name,
      required this.description,
      required this.common,
      required this.active,
      required this.onCreate,
      required this.onUpdate});
}

class HotelService {
  int id;
  String name;
  int unitPrice;
  String description;
  String onCreate;
  String onUpdate;

  HotelService(
      {required this.id,
      required this.name,
      required this.unitPrice,
      required this.description,
      required this.onCreate,
      required this.onUpdate});
}
