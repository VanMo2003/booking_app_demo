import '../../../../core/network/paged.dart';
import '../../data/models/account_models.dart';
import '../entities/account.dart';

abstract interface class AccountRepository {
  Future<Account> create(AccountCreateRequest request);

  Future<Account> update(String id, AccountUpdateRequest request);

  Future<Account> getById(String id);

  Future<Paged<Account>> getAll({required int page, required int size});
}
