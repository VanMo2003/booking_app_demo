import 'package:injectable/injectable.dart';

import '../domain/entities/payroll_entry.dart';

/// BE chưa có API đọc lại bảng lương theo cơ sở — giữ các phiếu tạo trong
/// phiên làm việc để còn cập nhật trạng thái.
@lazySingleton
class PayrollSessionStore {
  final Map<int, List<PayrollEntry>> _byHotel = {};

  List<PayrollEntry> read(int hotelId) =>
      List.unmodifiable(_byHotel[hotelId] ?? const <PayrollEntry>[]);

  void upsert(int hotelId, PayrollEntry entry) {
    final entries = [...?_byHotel[hotelId]];
    final index = entries.indexWhere((item) => item.id != null && item.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.insert(0, entry);
    }
    _byHotel[hotelId] = entries;
  }
}
