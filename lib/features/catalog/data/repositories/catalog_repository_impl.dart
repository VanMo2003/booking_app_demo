import 'package:injectable/injectable.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_api.dart';
import '../models/catalog_models.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._api);

  final CatalogApi _api;

  @override
  Future<List<CatalogItem>> list(CatalogKind kind) async {
    final response = switch (kind) {
      CatalogKind.roomType => await _api.roomTypes(),
      CatalogKind.position => await _api.positions(),
    };
    return response.parseList(CatalogItemModel.fromJson)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<CatalogItem> create(
    CatalogKind kind, {
    required String name,
    required String description,
  }) async {
    final body = CatalogItemModel.request(name: name, description: description);
    final response = switch (kind) {
      CatalogKind.roomType => await _api.createRoomType(body),
      CatalogKind.position => await _api.createPosition(body),
    };
    return response.parse(CatalogItemModel.fromJson);
  }

  @override
  Future<CatalogItem> update(
    CatalogKind kind,
    int id, {
    required String name,
    required String description,
  }) async {
    final body = CatalogItemModel.request(name: name, description: description);
    final response = switch (kind) {
      CatalogKind.roomType => await _api.updateRoomType(id, body),
      CatalogKind.position => await _api.updatePosition(id, body),
    };
    return response.parse(CatalogItemModel.fromJson);
  }

  @override
  Future<void> delete(CatalogKind kind, int id) async {
    final response = switch (kind) {
      CatalogKind.roomType => await _api.deleteRoomType(id),
      CatalogKind.position => await _api.deletePosition(id),
    };
    response.ensureSuccess();
  }
}
