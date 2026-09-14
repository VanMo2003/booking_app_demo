import 'package:equatable/equatable.dart';

import '../../../hotel/domain/entities/hotel.dart';

/// Chuỗi khách sạn — thuộc đúng một tài khoản chủ khách sạn.
class HotelChain extends Equatable {
  const HotelChain({
    required this.id,
    required this.name,
    this.description = '',
    this.pathImage,
    this.accountId,
  });

  final int id;
  final String name;
  final String description;
  final String? pathImage;
  final String? accountId;

  @override
  List<Object?> get props => [id, name, description, pathImage, accountId];
}

class HotelChainDetail extends Equatable {
  const HotelChainDetail({required this.chain, this.hotels = const []});

  final HotelChain chain;
  final List<Hotel> hotels;

  int get activeCount => hotels.where((h) => h.active).length;

  /// Tài khoản quản lý đang giữ ít nhất một cơ sở.
  Set<String> get managerAccountIds =>
      hotels.map((h) => h.accountId).whereType<String>().toSet();

  @override
  List<Object?> get props => [chain, hotels];
}
