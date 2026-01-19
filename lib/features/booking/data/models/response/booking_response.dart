// ignore_for_file: unnecessary_new, prefer_collection_literals

class BookingResponse {
  int? id;
  String? checkinDate;
  String? checkoutDate;
  String? bookingStatus;
  String? paymentMethod;
  HotelInfo? hotel;
  CustomerInfo? customer;
  List<BookingRooms>? bookingRooms;
  List<BookingServices>? bookingServices;
  int? totalAmount;
  String? note;
  String? onCreate;
  String? onUpdate;

  BookingResponse(
      {this.id,
      this.checkinDate,
      this.checkoutDate,
      this.bookingStatus,
      this.paymentMethod,
      this.hotel,
      this.customer,
      this.bookingRooms,
      this.bookingServices,
      this.totalAmount,
      this.note,
      this.onCreate,
      this.onUpdate});

  BookingResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    checkinDate = json['checkinDate'];
    checkoutDate = json['checkoutDate'];
    bookingStatus = json['bookingStatus'];
    paymentMethod = json['paymentMethod'];
    hotel =
        json['hotel'] != null ? new HotelInfo.fromJson(json['hotel']) : null;
    customer = json['customer'] != null
        ? new CustomerInfo.fromJson(json['customer'])
        : null;
    if (json['bookingRooms'] != null) {
      bookingRooms = <BookingRooms>[];
      json['bookingRooms'].forEach((v) {
        bookingRooms!.add(new BookingRooms.fromJson(v));
      });
    }
    if (json['bookingServices'] != null) {
      bookingServices = <BookingServices>[];
      json['bookingServices'].forEach((v) {
        bookingServices!.add(new BookingServices.fromJson(v));
      });
    }
    totalAmount = json['totalAmount'];
    note = json['note'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['checkinDate'] = checkinDate;
    data['checkoutDate'] = checkoutDate;
    data['bookingStatus'] = bookingStatus;
    data['paymentMethod'] = paymentMethod;
    if (hotel != null) {
      data['hotel'] = hotel!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (bookingRooms != null) {
      data['bookingRooms'] = bookingRooms!.map((v) => v.toJson()).toList();
    }
    if (bookingServices != null) {
      data['bookingServices'] =
          bookingServices!.map((v) => v.toJson()).toList();
    }
    data['totalAmount'] = totalAmount;
    data['note'] = note;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}

class HotelInfo {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? description;
  String? category;
  int? rating;
  String? pathImage;
  bool? active;

  HotelInfo(
      {this.id,
      this.name,
      this.address,
      this.phone,
      this.description,
      this.category,
      this.rating,
      this.pathImage,
      this.active});

  HotelInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    phone = json['phone'];
    description = json['description'];
    category = json['category'];
    rating = json['rating'];
    pathImage = json['pathImage'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['phone'] = phone;
    data['description'] = description;
    data['category'] = category;
    data['rating'] = rating;
    data['pathImage'] = pathImage;
    data['active'] = active;
    return data;
  }
}

class CustomerInfo {
  int? id;
  String? pathImage;
  String? fullName;
  String? phoneNumber;
  String? gender;
  String? hometown;

  CustomerInfo(
      {this.id,
      this.pathImage,
      this.fullName,
      this.phoneNumber,
      this.gender,
      this.hometown});

  CustomerInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    gender = json['gender'];
    hometown = json['hometown'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['gender'] = gender;
    data['hometown'] = hometown;
    return data;
  }
}

class BookingRooms {
  int? id;
  RoomInfo? roomInfo;

  BookingRooms({this.id, this.roomInfo});

  BookingRooms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomInfo = json['roomInfo'] != null
        ? new RoomInfo.fromJson(json['roomInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    if (roomInfo != null) {
      data['roomInfo'] = roomInfo!.toJson();
    }
    return data;
  }
}

class RoomInfo {
  int? id;
  String? pathImage;
  String? roomNumber;
  int? capacity;
  String? roomTypeName;

  RoomInfo(
      {this.id,
      this.pathImage,
      this.roomNumber,
      this.capacity,
      this.roomTypeName});

  RoomInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    roomNumber = json['roomNumber'];
    capacity = json['capacity'];
    roomTypeName = json['roomTypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['roomNumber'] = roomNumber;
    data['capacity'] = capacity;
    data['roomTypeName'] = roomTypeName;
    return data;
  }
}

class BookingServices {
  int? id;
  ServiceInfo? serviceInfo;

  BookingServices({this.id, this.serviceInfo});

  BookingServices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceInfo = json['serviceInfo'] != null
        ? new ServiceInfo.fromJson(json['serviceInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    if (serviceInfo != null) {
      data['serviceInfo'] = serviceInfo!.toJson();
    }
    return data;
  }
}

class ServiceInfo {
  int? id;
  String? name;

  ServiceInfo({this.id, this.name});

  ServiceInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
