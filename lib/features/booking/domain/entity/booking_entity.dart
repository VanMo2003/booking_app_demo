// ignore_for_file: unnecessary_new, prefer_collection_literals

class BookingEntity {
  int? id;
  String? checkinDate;
  String? checkoutDate;
  String? bookingStatus;
  String? paymentMethod;
  String? paymentStatus;
  HotelInfoEntity? hotel;
  CustomerInfoEntity? customer;
  List<BookingRoomsEntity>? bookingRooms;
  List<BookingServicesEntity>? bookingServices;
  int? totalAmount;
  String? note;
  String? onCreate;
  String? onUpdate;

  BookingEntity(
      {this.id,
      this.checkinDate,
      this.checkoutDate,
      this.bookingStatus,
      this.paymentMethod,
      this.paymentStatus,
      this.hotel,
      this.customer,
      this.bookingRooms,
      this.bookingServices,
      this.totalAmount,
      this.note,
      this.onCreate,
      this.onUpdate});
}

class HotelInfoEntity {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? description;
  String? category;
  int? rating;
  String? pathImage;
  bool? active;

  HotelInfoEntity(
      {this.id,
      this.name,
      this.address,
      this.phone,
      this.description,
      this.category,
      this.rating,
      this.pathImage,
      this.active});
}

class CustomerInfoEntity {
  int? id;
  String? pathImage;
  String? fullName;
  String? phoneNumber;
  String? gender;
  String? hometown;

  CustomerInfoEntity(
      {this.id,
      this.pathImage,
      this.fullName,
      this.phoneNumber,
      this.gender,
      this.hometown});
}

class BookingRoomsEntity {
  int? id;
  RoomInfoEntity? roomInfo;

  BookingRoomsEntity({this.id, this.roomInfo});
}

class RoomInfoEntity {
  int? id;
  String? pathImage;
  String? roomNumber;
  int? capacity;
  String? roomTypeName;

  RoomInfoEntity(
      {this.id,
      this.pathImage,
      this.roomNumber,
      this.capacity,
      this.roomTypeName});
}

class BookingServicesEntity {
  int? id;
  ServiceInfoEntity? serviceInfo;

  BookingServicesEntity({this.id, this.serviceInfo});
}

class ServiceInfoEntity {
  int? id;
  String? name;

  ServiceInfoEntity({this.id, this.name});
}
