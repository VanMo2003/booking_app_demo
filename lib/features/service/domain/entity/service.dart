class ServiceEntity {
  int? id;
  String? name;
  int? unitPrice;
  String? description;
  int? hotelId;
  String? hotelName;
  String? onCreate;
  String? onUpdate;

  ServiceEntity({
    this.id,
    this.name,
    this.unitPrice,
    this.description,
    this.hotelId,
    this.hotelName,
    this.onCreate,
    this.onUpdate,
  });

  ServiceEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unitPrice = json['unitPrice'];
    description = json['description'];
    hotelId = json['hotelId'];
    hotelName = json['hotelName'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['unitPrice'] = unitPrice;
    data['description'] = description;
    data['hotelId'] = hotelId;
    data['hotelName'] = hotelName;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
