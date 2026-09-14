import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveBytes({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
}) async {
  final data = Uint8List.fromList(bytes);
  final extension = fileName.contains('.') ? fileName.split('.').last : null;
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    bytes: data,
    type: extension == null ? FileType.any : FileType.custom,
    allowedExtensions: extension == null ? null : [extension],
  );
  if (path == null) return false;

  // Trên desktop, file_picker chỉ trả đường dẫn đã chọn chứ không ghi file.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await File(path).writeAsBytes(data, flush: true);
  }
  return true;
}
