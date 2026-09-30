import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';

/// Định dạng hiển thị: tiền VND, ngày theo kiểu Việt Nam, phần trăm.
abstract final class Fmt {
  static final NumberFormat _integer = NumberFormat.decimalPattern('vi_VN');
  static final NumberFormat _oneDecimal = NumberFormat('#,##0.#', 'vi_VN');

  /// 1050000 → "1.050.000 ₫"
  static String money(num? value) =>
      '${_integer.format((value ?? 0).round())} ₫';

  /// 1250000 → "1,3 tr" — dùng cho trục biểu đồ, thẻ số liệu.
  static String moneyCompact(num? value) {
    final v = (value ?? 0).toDouble();
    final abs = v.abs();
    if (abs >= 1e9) return '${_oneDecimal.format(v / 1e9)} tỷ';
    if (abs >= 1e6) return '${_oneDecimal.format(v / 1e6)} tr';
    if (abs >= 1e3) return '${_oneDecimal.format(v / 1e3)} N';
    return _integer.format(v.round());
  }

  static String number(num? value) => _integer.format(value ?? 0);

  /// 66.67 → "66,7%"
  static String percent(num? value) => '${_oneDecimal.format(value ?? 0)}%';

  static String date(DateTime? d) =>
      d == null ? '--/--/----' : DateFormat('dd/MM/yyyy').format(d);

  static String dayMonth(DateTime? d) =>
      d == null ? '--/--' : DateFormat('dd/MM').format(d);

  /// "T5, 02/10"
  static String weekdayDate(DateTime d) =>
      '${_weekdayShort(d.weekday)}, ${DateFormat('dd/MM').format(d)}';

  static String weekdayLong(DateTime d) => _weekdayLong(d.weekday);

  static String dateTime(DateTime? d) =>
      d == null ? '' : DateFormat('HH:mm · dd/MM/yyyy').format(d);

  /// "14:05"
  static String time(DateTime d) => DateFormat('HH:mm').format(d);

  /// Mốc thời gian gọn cho danh sách tin nhắn: "14:05", "Hôm qua", "T5",
  /// "02/10", "02/10/25".
  static String chatTime(DateTime? d, {DateTime? now}) {
    if (d == null) return '';
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final day = DateUtils.dateOnly(d);
    final days = today.difference(day).inDays;
    if (days <= 0) return time(d);
    if (days == 1) return 'Hôm qua';
    if (days < 7) return _weekdayShort(d.weekday);
    if (d.year == today.year) return DateFormat('dd/MM').format(d);
    return DateFormat('dd/MM/yy').format(d);
  }

  /// Định dạng gửi lên API: "2026-10-02".
  static String apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static String monthYear(int month, int year) =>
      'Tháng ${month.toString().padLeft(2, '0')}/$year';

  static String monthShort(int month) => 'T$month';

  /// 04:35 hoặc 1:04:35
  static String countdown(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  static String initials(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.firstLetter.toUpperCase();
    return (parts.first.firstLetter + parts.last.firstLetter).toUpperCase();
  }

  static String _weekdayShort(int weekday) => switch (weekday) {
        DateTime.monday => 'T2',
        DateTime.tuesday => 'T3',
        DateTime.wednesday => 'T4',
        DateTime.thursday => 'T5',
        DateTime.friday => 'T6',
        DateTime.saturday => 'T7',
        _ => 'CN',
      };

  static String _weekdayLong(int weekday) => switch (weekday) {
        DateTime.monday => 'Thứ Hai',
        DateTime.tuesday => 'Thứ Ba',
        DateTime.wednesday => 'Thứ Tư',
        DateTime.thursday => 'Thứ Năm',
        DateTime.friday => 'Thứ Sáu',
        DateTime.saturday => 'Thứ Bảy',
        _ => 'Chủ Nhật',
      };
}

extension _FirstLetter on String {
  String get firstLetter => isEmpty ? '' : String.fromCharCode(runes.first);
}
