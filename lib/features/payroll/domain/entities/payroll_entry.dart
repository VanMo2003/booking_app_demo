import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

/// Phiếu lương. BE chỉ trả `id` sau khi tạo, nên phần còn lại do FE giữ.
class PayrollEntry extends Equatable {
  const PayrollEntry({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.totalSalary,
    required this.status,
  });

  final int? id;
  final int employeeId;
  final String employeeName;

  /// Ngày 1 của tháng lương.
  final DateTime month;
  final double totalSalary;
  final PayrollStatus status;

  PayrollEntry copyWith({int? id, PayrollStatus? status, double? totalSalary}) =>
      PayrollEntry(
        id: id ?? this.id,
        employeeId: employeeId,
        employeeName: employeeName,
        month: month,
        totalSalary: totalSalary ?? this.totalSalary,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [id, employeeId, employeeName, month, totalSalary, status];
}
