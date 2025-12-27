import '../../../domain/entity/room_type.dart';

class RoomTypeResponse {
  int? id;
  String? name;
  String? description;

  RoomTypeResponse({this.id, this.name, this.description});

  RoomTypeResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    return data;
  }

  RoomType toEntity() => RoomType(id: id, name: name, description: description);
}
