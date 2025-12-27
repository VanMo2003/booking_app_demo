class ServiceUpdateDto {
  String? name;
  int? unitPrice;
  String? description;

  ServiceUpdateDto({this.name, this.unitPrice, this.description});

  ServiceUpdateDto.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unitPrice = json['unitPrice'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['unitPrice'] = unitPrice;
    data['description'] = description;
    return data;
  }
}
