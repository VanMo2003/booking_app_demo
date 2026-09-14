import '../entities/payroll_entry.dart';

abstract interface class PayrollRepository {
  /// Trả về id phiếu vừa tạo (BE chỉ trả id).
  Future<int> create(PayrollEntry entry);

  Future<void> update(PayrollEntry entry);
}
