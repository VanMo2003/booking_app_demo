class RoomTypeCreateDto {
  String? name;
  String? description;

  RoomTypeCreateDto({this.name, this.description});

  RoomTypeCreateDto.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    return data;
  }
}
