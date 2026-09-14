import 'package:injectable/injectable.dart';

import '../entities/payroll_entry.dart';
import '../repositories/payroll_repository.dart';

@injectable
class SavePayroll {
  const SavePayroll(this._repository);

  final PayrollRepository _repository;

  /// Chưa có id → tạo phiếu mới; có id → cập nhật.
  Future<PayrollEntry> call(PayrollEntry entry) async {
    if (entry.id == null) {
      final id = await _repository.create(entry);
      return entry.copyWith(id: id);
    }
    await _repository.update(entry);
    return entry;
  }
}
