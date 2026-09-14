import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../account/domain/entities/account.dart';
import '../../../account/domain/repositories/account_repository.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../employee/domain/repositories/employee_repository.dart';
import '../../../hotel/domain/repositories/hotel_repository.dart';
import '../../../hotel_chain/domain/repositories/hotel_chain_repository.dart';

class SystemOverview extends Equatable {
  const SystemOverview({
    required this.accounts,
    required this.chains,
    required this.branches,
    required this.customers,
    required this.employees,
    required this.recentAccounts,
  });

  final int accounts;
  final int chains;
  final int branches;
  final int customers;
  final int employees;
  final List<Account> recentAccounts;

  @override
  List<Object?> get props =>
      [accounts, chains, branches, customers, employees, recentAccounts];
}

/// Đếm nhanh bằng `totalElements` của các API phân trang.
@injectable
class LoadSystemOverview {
  const LoadSystemOverview(
    this._accounts,
    this._chains,
    this._hotels,
    this._customers,
    this._employees,
  );

  final AccountRepository _accounts;
  final HotelChainRepository _chains;
  final HotelRepository _hotels;
  final CustomerRepository _customers;
  final EmployeeRepository _employees;

  Future<SystemOverview> call() async {
    final accounts = _accounts.getAll(page: 0, size: 5);
    final chains = _chains.getAll(page: 0, size: 1);
    final hotels = _hotels.getHotels(page: 0, size: 1);
    final customers = _customers.getAll(page: 0, size: 1);
    final employees = _employees.getAll(page: 0, size: 1);
    final accountPage = await accounts;
    return SystemOverview(
      accounts: accountPage.totalElements,
      chains: (await chains).totalElements,
      branches: (await hotels).totalElements,
      customers: (await customers).totalElements,
      employees: (await employees).totalElements,
      recentAccounts: accountPage.items,
    );
  }
}
