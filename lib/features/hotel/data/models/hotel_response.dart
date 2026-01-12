class HotelResponse {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? description;
  String? category;
  int? rating;
  String? pathImage;
  bool? active;
  String? accountId;
  List<HotelRoomResponse>? rooms;
  List<HotelAmenitieResponse>? amenities;
  List<HotelServicesResponse>? services;
  String? onCreate;
  String? onUpdate;

  HotelResponse(
      {this.id,
      this.name,
      this.address,
      this.phone,
      this.description,
      this.category,
      this.rating,
      this.pathImage,
      this.active,
      this.accountId,
      this.rooms,
      this.amenities,
      this.services,
      this.onCreate,
      this.onUpdate});

  HotelResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    phone = json['phone'];
    description = json['description'];
    category = json['category'];
    rating = json['rating'];
    pathImage = json['pathImage'];
    active = json['active'];
    accountId = json['accountId'];
    if (json['rooms'] != null) {
      rooms = <HotelRoomResponse>[];
      json['rooms'].forEach((v) {
        rooms!.add(new HotelRoomResponse.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <HotelAmenitieResponse>[];
      json['amenities'].forEach((v) {
        amenities!.add(new HotelAmenitieResponse.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <HotelServicesResponse>[];
      json['services'].forEach((v) {
        services!.add(new HotelServicesResponse.fromJson(v));
      });
    }
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['description'] = this.description;
    data['category'] = this.category;
    data['rating'] = this.rating;
    data['pathImage'] = this.pathImage;
    data['active'] = this.active;
    data['accountId'] = this.accountId;
    if (this.rooms != null) {
      data['rooms'] = this.rooms!.map((v) => v.toJson()).toList();
    }
    if (this.amenities != null) {
      data['amenities'] = this.amenities!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}

class HotelRoomResponse {
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

  HotelRoomResponse(
      {this.id,
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
      this.onUpdate});

  HotelRoomResponse.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pathImage'] = this.pathImage;
    data['roomNumber'] = this.roomNumber;
    data['price'] = this.price;
    data['description'] = this.description;
    data['capacity'] = this.capacity;
    data['status'] = this.status;
    data['hotelId'] = this.hotelId;
    data['hotelName'] = this.hotelName;
    data['roomTypeId'] = this.roomTypeId;
    data['roomTypeName'] = this.roomTypeName;
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}

class HotelAmenitieResponse {
  int? id;
  String? name;
  String? description;
  bool? common;
  bool? active;
  String? onCreate;
  String? onUpdate;

  HotelAmenitieResponse(
      {this.id,
      this.name,
      this.description,
      this.common,
      this.active,
      this.onCreate,
      this.onUpdate});

  HotelAmenitieResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    common = json['common'];
    active = json['active'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['common'] = this.common;
    data['active'] = this.active;
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}

class HotelServicesResponse {
  int? id;
  String? name;
  int? unitPrice;
  String? description;
  String? onCreate;
  String? onUpdate;

  HotelServicesResponse(
      {this.id,
      this.name,
      this.unitPrice,
      this.description,
      this.onCreate,
      this.onUpdate});

  HotelServicesResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unitPrice = json['unitPrice'];
    description = json['description'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['unitPrice'] = this.unitPrice;
    data['description'] = this.description;
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}
