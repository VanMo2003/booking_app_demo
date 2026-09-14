import '../../../../core/network/json_reader.dart';
import '../../domain/entities/catalog_item.dart';

/// JSON `RoomTypeResponse` / `PositionResponse` ↔ [CatalogItem].
abstract final class CatalogItemModel {
  static CatalogItem fromJson(Json json) => CatalogItem(
        id: json.integer('id'),
        name: json.str('name'),
        description: json.str('description'),
      );

  static Map<String, dynamic> request({
    required String name,
    required String description,
  }) =>
      {'name': name, 'description': description};
}
