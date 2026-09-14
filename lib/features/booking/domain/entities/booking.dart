import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/utils/date_utils.dart';

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    this.paymentExpireAt,
    this.paidAt,
    this.hotel,
    this.customer,
    this.rooms = const [],
    this.services = const [],
    this.note,
    this.handledByAccountId,
    this.createdAt,
  });

  final int id;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final DateTime? paymentExpireAt;
  final DateTime? paidAt;
  final BookingHotel? hotel;
  final BookingCustomer? customer;
  final List<BookedRoom> rooms;
  final List<BookedService> services;
  final String? note;

  /// Tài khoản nhân viên tạo đơn tại quầy; `null` nếu khách tự đặt.
  final String? handledByAccountId;
  final DateTime? createdAt;

  int get nights => DateOnly.nights(checkinDate, checkoutDate);

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get createdAtDesk => (handledByAccountId ?? '').isNotEmpty;

  /// Đơn VNPay chưa thanh toán và vẫn còn mở — khách có thể thanh toán (lại).
  bool get canPayOnline =>
      paymentMethod == PaymentMethod.vnPay && !isPaid && status.isOpen;

  String get roomNumbers => rooms.map((r) => r.roomNumber).join(', ');

  @override
  List<Object?> get props => [
        id,
        checkinDate,
        checkoutDate,
        status,
        paymentMethod,
        paymentStatus,
        totalAmount,
        paymentExpireAt,
        paidAt,
        hotel,
        customer,
        rooms,
        services,
        note,
        handledByAccountId,
        createdAt,
      ];
}

class BookingHotel extends Equatable {
  const BookingHotel({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.category = '',
    this.rating = 0,
    this.pathImage,
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final String category;
  final int rating;
  final String? pathImage;

  @override
  List<Object?> get props => [id, name, address, phone, category, rating, pathImage];
}

class BookingCustomer extends Equatable {
  const BookingCustomer({
    required this.id,
    required this.fullName,
    this.phoneNumber = '',
    this.pathImage,
    this.gender = '',
    this.hometown = '',
  });

  final int id;
  final String fullName;
  final String phoneNumber;
  final String? pathImage;
  final String gender;
  final String hometown;

  @override
  List<Object?> get props => [id, fullName, phoneNumber, pathImage, gender, hometown];
}

class BookedRoom extends Equatable {
  const BookedRoom({
    required this.roomId,
    required this.roomNumber,
    this.capacity = 0,
    this.roomTypeName = '',
    this.pathImage,
  });

  final int roomId;
  final String roomNumber;
  final int capacity;
  final String roomTypeName;
  final String? pathImage;

  @override
  List<Object?> get props => [roomId, roomNumber, capacity, roomTypeName, pathImage];
}

class BookedService extends Equatable {
  const BookedService({required this.serviceId, required this.name});

  final int serviceId;
  final String name;

  @override
  List<Object?> get props => [serviceId, name];
}
