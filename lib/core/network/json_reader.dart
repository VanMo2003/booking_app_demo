typedef Json = Map<String, dynamic>;

/// Đọc JSON an toàn: BE trả BigDecimal có thể là `500000` hoặc `500000.00`,
/// trường null bị lược khỏi body, ngày có nhiều định dạng.
extension JsonReader on Json {
  String str(String key, [String fallback = '']) {
    final value = this[key];
    return value == null ? fallback : value.toString();
  }

  String? strOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int integer(String key, [int fallback = 0]) => intOrNull(key) ?? fallback;

  int? intOrNull(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double decimal(String key, [double fallback = 0]) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  bool flag(String key, [bool fallback = false]) {
    final value = this[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  /// Ngày giờ: "2026-09-13T10:45:00" (giờ máy chủ) hoặc
  /// "2026-09-13T03:30:00.000+00:00" (UTC) → quy về giờ máy.
  DateTime? dateTime(String key) {
    final value = this[key];
    if (value is! String || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.isUtc == true ? parsed!.toLocal() : parsed;
  }

  /// Ngày không giờ: "2026-10-02".
  DateTime? date(String key) {
    final value = this[key];
    if (value is! String || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  Json? obj(String key) {
    final value = this[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  List<T> listOf<T>(String key, T Function(Json json) parse) {
    final value = this[key];
    if (value is! List) return <T>[];
    return value
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<String> strings(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
}
