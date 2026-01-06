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