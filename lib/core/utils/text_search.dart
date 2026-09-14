/// Tìm kiếm tiếng Việt không phân biệt dấu và hoa thường: "tran thi" khớp "Trần Thị".
abstract final class TextSearch {
  static final Map<String, String> _accents = {
    for (final c in 'àáạảãâầấậẩẫăằắặẳẵ'.split('')) c: 'a',
    for (final c in 'èéẹẻẽêềếệểễ'.split('')) c: 'e',
    for (final c in 'ìíịỉĩ'.split('')) c: 'i',
    for (final c in 'òóọỏõôồốộổỗơờớợởỡ'.split('')) c: 'o',
    for (final c in 'ùúụủũưừứựửữ'.split('')) c: 'u',
    for (final c in 'ỳýỵỷỹ'.split('')) c: 'y',
    'đ': 'd',
  };

  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  static bool matches(String text, String query) {
    final needle = normalize(query.trim());
    return needle.isEmpty || normalize(text).contains(needle);
  }
}
