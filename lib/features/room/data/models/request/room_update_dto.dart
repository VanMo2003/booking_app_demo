class RoomUpdateDto {
  String? roomNumber;
  int? price;
  String? description;
  int? capacity;
  int? roomTypeId;
  String? status;
  List<String>? images;

  RoomUpdateDto(
      {this.roomNumber,
      this.price,
      this.description,
      this.capacity,
      this.roomTypeId,
      this.status,
      this.images});

  RoomUpdateDto.fromJson(Map<String, dynamic> json) {
    roomNumber = json['roomNumber'];
    price = json['price'];
    description = json['description'];
    capacity = json['capacity'];
    roomTypeId = json['roomTypeId'];
    status = json['status'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomNumber'] = roomNumber;
    data['price'] = price;
    data['description'] = description;
    data['capacity'] = capacity;
    data['roomTypeId'] = roomTypeId;
    data['status'] = status;
    if (images != null) data['images'] = images;
    return data;
  }
}
