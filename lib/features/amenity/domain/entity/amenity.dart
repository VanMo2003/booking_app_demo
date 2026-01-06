import 'package:equatable/equatable.dart';

class Amenity extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool common;
  final bool active;
  final String? hotelName;
  final DateTime? onCreate;
  final DateTime? onUpdate;

  const Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.common,
    required this.active,
    this.hotelName,
    this.onCreate,
    this.onUpdate,
  });

  @override
  List<Object?> get props =>
      [id, name, description, common, active, hotelName, onCreate, onUpdate];
}
