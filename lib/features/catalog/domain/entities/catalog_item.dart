import 'package:equatable/equatable.dart';

/// Danh mục dùng chung toàn hệ thống.
enum CatalogKind { roomType, position }

/// Loại phòng hoặc chức vụ — cùng hình dạng `{id, name, description}`.
class CatalogItem extends Equatable {
  const CatalogItem({required this.id, required this.name, this.description = ''});

  final int id;
  final String name;
  final String description;

  @override
  List<Object?> get props => [id, name, description];
}
