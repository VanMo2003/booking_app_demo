import 'package:injectable/injectable.dart';

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

/// Quản trị viên khoá hoặc mở tài khoản. Tài khoản chủ khách sạn tự đăng ký
/// và được duyệt; quản lý do chủ khách sạn tạo — admin không tạo tài khoản.
@injectable
class SetAccountActive {
  const SetAccountActive(this._repository);

  final AccountRepository _repository;

  Future<Account> call(String id, {required bool active}) =>
      _repository.update(id, AccountUpdateRequest(active: active));
}
