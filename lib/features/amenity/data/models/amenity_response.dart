class AmenityResponse {
  int? id;
  String? name;
  String? description;
  bool? common;
  bool? active;
  String? hotelName;
  String? onCreate;
  String? onUpdate;

  AmenityResponse(
      {this.id,
        this.name,
        this.description,
        this.common,
        this.active,
        this.hotelName,
        this.onCreate,
        this.onUpdate});

  AmenityResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    common = json['common'];
    active = json['active'];
    hotelName = json['hotelName'];
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
    data['hotelName'] = this.hotelName;
    data['onCreate'] = this.onCreate;
    data['onUpdate'] = this.onUpdate;
    return data;
  }
}
