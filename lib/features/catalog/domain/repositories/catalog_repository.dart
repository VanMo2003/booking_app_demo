import '../entities/catalog_item.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogItem>> list(CatalogKind kind);

  Future<CatalogItem> create(
    CatalogKind kind, {
    required String name,
    required String description,
  });

  Future<CatalogItem> update(
    CatalogKind kind,
    int id, {
    required String name,
    required String description,
  });

  Future<void> delete(CatalogKind kind, int id);
}
