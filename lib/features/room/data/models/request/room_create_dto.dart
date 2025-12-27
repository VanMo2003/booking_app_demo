class RoomCreateDto {
  String? roomNumber;
  int? price;
  String? description;
  int? capacity;
  int? hotelId;
  int? roomTypeId;

  RoomCreateDto(
      {this.roomNumber,
      this.price,
      this.description,
      this.capacity,
      this.hotelId,
      this.roomTypeId});

  RoomCreateDto.fromJson(Map<String, dynamic> json) {
    roomNumber = json['roomNumber'];
    price = json['price'];
    description = json['description'];
    capacity = json['capacity'];
    hotelId = json['hotelId'];
    roomTypeId = json['roomTypeId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomNumber'] = roomNumber;
    data['price'] = price;
    data['description'] = description;
    data['capacity'] = capacity;
    data['hotelId'] = hotelId;
    data['roomTypeId'] = roomTypeId;
    return data;
  }
}
