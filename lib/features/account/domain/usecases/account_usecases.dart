import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/paged.dart';
import '../../data/models/account_models.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

@injectable
class GetAccountsPage {
  const GetAccountsPage(this._repository);

  final AccountRepository _repository;

  Future<Paged<Account>> call({required int page, required int size}) =>
      _repository.getAll(page: page, size: size);
}

@injectable
class GetAccount {
  const GetAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(String id) => _repository.getById(id);
}

/// Admin tạo ADMIN / HOTEL_OWNER / HOTEL_MANAGER; chủ khách sạn chỉ tạo HOTEL_MANAGER.
@injectable
class CreateAccount {
  const CreateAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call({
    required String username,
    required String password,
    required Role role,
  }) =>
      _repository.create(
        AccountCreateRequest(username: username, password: password, role: role),
      );
}

@injectable
class UpdateAccount {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(String id, {Role? role, bool? active}) =>
      _repository.update(id, AccountUpdateRequest(role: role, active: active));
}

@injectable
class DeleteAccount {
  const DeleteAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
