class RoomUpdateDto {
  String? roomNumber;
  int? price;
  String? description;
  int? capacity;
  int? roomTypeId;
  String? status;

  RoomUpdateDto(
      {this.roomNumber,
      this.price,
      this.description,
      this.capacity,
      this.roomTypeId,
      this.status});

  RoomUpdateDto.fromJson(Map<String, dynamic> json) {
    roomNumber = json['roomNumber'];
    price = json['price'];
    description = json['description'];
    capacity = json['capacity'];
    roomTypeId = json['roomTypeId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomNumber'] = roomNumber;
    data['price'] = price;
    data['description'] = description;
    data['capacity'] = capacity;
    data['roomTypeId'] = roomTypeId;
    data['status'] = status;
    return data;
  }
}
