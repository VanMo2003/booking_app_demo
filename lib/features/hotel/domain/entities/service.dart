import 'package:equatable/equatable.dart';

class HotelService extends Equatable {
  final int id;
  final String name;
  final int unitPrice;
  final String description;
  final DateTime? onCreate;
  final DateTime? onUpdate;

  const HotelService({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.description,
    this.onCreate,
    this.onUpdate,
  });

  @override
  List<Object?> get props => [id, name, unitPrice, description, onCreate, onUpdate];
}
