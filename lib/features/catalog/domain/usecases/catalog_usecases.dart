import 'package:injectable/injectable.dart';

import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

@injectable
class GetCatalog {
  const GetCatalog(this._repository);

  final CatalogRepository _repository;

  Future<List<CatalogItem>> call(CatalogKind kind) => _repository.list(kind);
}

@injectable
class SaveCatalogItem {
  const SaveCatalogItem(this._repository);

  final CatalogRepository _repository;

  /// [id] rỗng → tạo mới.
  Future<CatalogItem> call(
    CatalogKind kind, {
    int? id,
    required String name,
    required String description,
  }) =>
      id == null
          ? _repository.create(kind, name: name, description: description)
          : _repository.update(kind, id, name: name, description: description);
}

@injectable
class DeleteCatalogItem {
  const DeleteCatalogItem(this._repository);

  final CatalogRepository _repository;

  Future<void> call(CatalogKind kind, int id) => _repository.delete(kind, id);
}
