import 'package:injectable/injectable.dart';

import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/payroll_entry.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../datasources/payroll_api.dart';

@LazySingleton(as: PayrollRepository)
class PayrollRepositoryImpl implements PayrollRepository {
  PayrollRepositoryImpl(this._api);

  final PayrollApi _api;

  Map<String, dynamic> _body(PayrollEntry entry) => {
        'month': Fmt.apiDate(DateTime(entry.month.year, entry.month.month)),
        'totalSalary': entry.totalSalary.round(),
        'employeeId': entry.employeeId,
        'status': entry.status.value,
      };

  @override
  Future<int> create(PayrollEntry entry) async =>
      (await _api.create(_body(entry))).json.integer('id');

  @override
  Future<void> update(PayrollEntry entry) async =>
      (await _api.update(entry.id!, _body(entry))).ensureSuccess();
}
