import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_api.dart';
import '../models/account_models.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._api);

  final AccountApi _api;

  @override
  Future<Account> create(AccountCreateRequest request) async =>
      (await _api.create(request.toJson())).parse(AccountModel.fromJson);

  @override
  Future<Account> update(String id, AccountUpdateRequest request) async =>
      (await _api.update(id, request.toJson())).parse(AccountModel.fromJson);

  @override
  Future<Account> getById(String id) async =>
      (await _api.getById(id)).parse(AccountModel.fromJson);

  @override
  Future<Paged<Account>> getAll({required int page, required int size}) async =>
      (await _api.getAll(page, size)).parsePage(AccountModel.fromJson);

  @override
  Future<void> delete(String id) async => (await _api.delete(id)).ensureSuccess();
}
