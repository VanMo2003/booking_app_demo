class ServiceCreateDto {
  String? name;
  int? unitPrice;
  String? description;
  int? hotelId;

  ServiceCreateDto({this.name, this.unitPrice, this.description, this.hotelId});

  ServiceCreateDto.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unitPrice = json['unitPrice'];
    description = json['description'];
    hotelId = json['hotelId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['unitPrice'] = unitPrice;
    data['description'] = description;
    data['hotelId'] = hotelId;
    return data;
  }
}
