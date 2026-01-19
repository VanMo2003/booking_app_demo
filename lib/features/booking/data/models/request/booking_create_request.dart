// ignore_for_file: unnecessary_new, prefer_collection_literals

class BookingCreateRequest {
  String? checkinDate;
  String? checkoutDate;
  String? paymentMethod;
  int? hotelId;
  int? customerId;
  List<int>? rooms;
  List<int>? services;
  int? totalAmount;
  String? note;

  BookingCreateRequest(
      {this.checkinDate,
      this.checkoutDate,
      this.paymentMethod,
      this.hotelId,
      this.customerId,
      this.rooms,
      this.services,
      this.totalAmount,
      this.note});

  BookingCreateRequest.fromJson(Map<String, dynamic> json) {
    checkinDate = json['checkinDate'];
    checkoutDate = json['checkoutDate'];
    paymentMethod = json['paymentMethod'];
    hotelId = json['hotelId'];
    customerId = json['customerId'];
    rooms = json['rooms'].cast<int>();
    services = json['services'].cast<int>();
    totalAmount = json['totalAmount'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkinDate'] = checkinDate;
    data['checkoutDate'] = checkoutDate;
    data['paymentMethod'] = paymentMethod;
    data['hotelId'] = hotelId;
    data['customerId'] = customerId;
    data['rooms'] = rooms;
    data['services'] = services;
    data['totalAmount'] = totalAmount;
    data['note'] = note;
    return data;
  }
}
