import 'file_saver_stub.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart' as platform;

/// Lưu file nhị phân (báo cáo Excel) theo cách phù hợp từng nền tảng:
/// di động mở hộp thoại lưu của hệ điều hành, web tải xuống qua trình duyệt.
abstract final class FileSaver {
  static const excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// `true` khi đã lưu, `false` khi người dùng huỷ.
  static Future<bool> save({
    required List<int> bytes,
    required String fileName,
    String mimeType = excelMimeType,
  }) =>
      platform.saveBytes(bytes: bytes, fileName: fileName, mimeType: mimeType);
}
