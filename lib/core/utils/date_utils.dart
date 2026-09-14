/// Làm việc với ngày không kèm giờ (ngày nhận/trả phòng, khoảng báo cáo).
abstract final class DateOnly {
  static DateTime today() => of(DateTime.now());

  static DateTime of(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Số đêm giữa hai ngày; tính theo UTC để không lệch vì giờ mùa hè.
  static int nights(DateTime checkin, DateTime checkout) {
    final a = DateTime.utc(checkin.year, checkin.month, checkin.day);
    final b = DateTime.utc(checkout.year, checkout.month, checkout.day);
    return b.difference(a).inDays;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  static DateTime addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  /// Mọi ngày trong [from, to] (tính cả hai đầu).
  static List<DateTime> daysInRange(DateTime from, DateTime to) {
    final result = <DateTime>[];
    var cursor = of(from);
    final end = of(to);
    while (!cursor.isAfter(end)) {
      result.add(cursor);
      cursor = addDays(cursor, 1);
    }
    return result;
  }

  /// `from` ≤ ngày < `to`, dùng cho ngày lưu trú.
  static bool isWithinStay(DateTime day, DateTime checkin, DateTime checkout) {
    final d = of(day);
    return !d.isBefore(of(checkin)) && d.isBefore(of(checkout));
  }
}
