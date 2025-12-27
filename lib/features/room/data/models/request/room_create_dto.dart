class RoomCreateDto {
  String? roomNumber;
  int? price;
  String? description;
  int? capacity;
  int? hotelId;
  int? roomTypeId;
  List<String>? images;

  RoomCreateDto(
      {this.roomNumber,
      this.price,
      this.description,
      this.capacity,
      this.hotelId,
      this.roomTypeId,
      this.images});

  RoomCreateDto.fromJson(Map<String, dynamic> json) {
    roomNumber = json['roomNumber'];
    price = json['price'];
    description = json['description'];
    capacity = json['capacity'];
    hotelId = json['hotelId'];
    roomTypeId = json['roomTypeId'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomNumber'] = roomNumber;
    data['price'] = price;
    data['description'] = description;
    data['capacity'] = capacity;
    data['hotelId'] = hotelId;
    data['roomTypeId'] = roomTypeId;
    if (images != null) data['images'] = images;
    return data;
  }
}
