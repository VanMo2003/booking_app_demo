import 'package:equatable/equatable.dart';

/// Dịch vụ tính thêm tiền của cơ sở (giặt ủi, đưa đón…).
class HotelService extends Equatable {
  const HotelService({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.description = '',
  });

  final int id;
  final String name;
  final double unitPrice;
  final String description;

  @override
  List<Object?> get props => [id, name, unitPrice, description];
}
