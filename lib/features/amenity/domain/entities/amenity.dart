import 'package:equatable/equatable.dart';

class Amenity extends Equatable {
  const Amenity({
    required this.id,
    required this.name,
    this.description = '',
    this.common = true,
    this.active = true,
    this.hotelName,
    this.roomName,
  });

  final int id;
  final String name;
  final String description;

  /// `true`: tiện ích chung của cơ sở; `false`: gắn cho phòng cụ thể.
  final bool common;
  final bool active;
  final String? hotelName;
  final String? roomName;

  @override
  List<Object?> get props => [id, name, description, common, active, hotelName, roomName];
}
