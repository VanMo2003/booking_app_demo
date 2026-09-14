import 'package:equatable/equatable.dart';

/// Ảnh chụp gọn một cơ sở được lưu yêu thích trên máy
/// (BE chưa có API yêu thích).
class FavoriteHotel extends Equatable {
  const FavoriteHotel({
    required this.id,
    required this.name,
    this.address = '',
    this.category = '',
    this.rating = 0,
    this.pathImage,
  });

  final int id;
  final String name;
  final String address;
  final String category;
  final int rating;
  final String? pathImage;

  @override
  List<Object?> get props => [id, name, address, category, rating, pathImage];
}
