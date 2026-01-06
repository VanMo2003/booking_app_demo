import 'hotel_service_response.dart';

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
  List<Null>? amenities;
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
    // if (json['amenities'] != null) {
    //   amenities = <Null>[];
    //   json['amenities'].forEach((v) {
    //     amenities!.add(new Null.fromJson(v));
    //   });
    // }
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
    // if (this.amenities != null) {
    //   data['amenities'] = this.amenities!.map((v) => v!.toJson()).toList();
    // }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}