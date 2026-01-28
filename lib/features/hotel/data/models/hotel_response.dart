class HotelResponse {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? description;
  String? category;
  int? rating;
  String? pathImage;
  List<String>? images;
  bool? active;
  String? accountId;
  List<HotelRoomResponse>? rooms;
  List<HotelAmenitieResponse>? amenities;
  List<HotelServicesResponse>? services;
  String? status;
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
      this.images,
      this.active,
      this.accountId,
      this.rooms,
      this.amenities,
      this.services,
      this.status,
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
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    active = json['active'];
    accountId = json['accountId'];
    if (json['rooms'] != null) {
      rooms = <HotelRoomResponse>[];
      json['rooms'].forEach((v) {
        rooms!.add(HotelRoomResponse.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <HotelAmenitieResponse>[];
      json['amenities'].forEach((v) {
        amenities!.add(HotelAmenitieResponse.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <HotelServicesResponse>[];
      json['services'].forEach((v) {
        services!.add(HotelServicesResponse.fromJson(v));
      });
    }
    status = json['status'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['phone'] = phone;
    data['description'] = description;
    data['category'] = category;
    data['rating'] = rating;
    data['pathImage'] = pathImage;
    if (images != null) data['images'] = images;
    data['active'] = active;
    data['accountId'] = accountId;
    if (rooms != null) {
      data['rooms'] = rooms!.map((v) => v.toJson()).toList();
    }
    if (amenities != null) {
      data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['common'] = common;
    data['active'] = active;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['unitPrice'] = unitPrice;
    data['description'] = description;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
