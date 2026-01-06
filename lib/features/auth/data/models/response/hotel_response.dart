import 'dart:developer';

class HotelInfoResponse {
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
  Null? amenities;
  List<Service>? services;
  String? onCreate;
  String? onUpdate;

  HotelInfoResponse(
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
      this.amenities,
      this.services,
      this.onCreate,
      this.onUpdate});

  HotelInfoResponse.fromJson(Map<String, dynamic> json) {
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
    amenities = json['amenities'];
    services = json['services'];
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
    data['active'] = active;
    data['accountId'] = accountId;
    data['amenities'] = amenities;
    data['services'] = services;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
