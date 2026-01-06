import 'package:equatable/equatable.dart';
import 'service.dart';

class Hotel extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String category;
  final int rating;
  final String pathImage;
  final bool active;
  final String accountId;
  final List<dynamic> amenities;
  final List<HotelService> services;
  final DateTime? onCreate;
  final DateTime? onUpdate;

  const Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.category,
    required this.rating,
    required this.pathImage,
    required this.active,
    required this.accountId,
    required this.amenities,
    required this.services,
    this.onCreate,
    this.onUpdate,
  });

  @override
  List<Object?> get props => [
        id, name, address, phone, description, category, rating, pathImage,
        active, accountId, amenities, services, onCreate, onUpdate
      ];
}
