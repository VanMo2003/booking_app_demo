import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// File chọn từ máy (bytes) để gửi multipart — chạy được cả web lẫn di động.
class UploadFile {
  const UploadFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  MultipartFile toMultipart() => MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: DioMediaType.parse(_mimeType(name)),
      );

  static String _mimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}

/// Phần JSON `data` trong request multipart (Spring `@RequestPart("data")`).
MultipartFile jsonPart(Map<String, dynamic> payload) => MultipartFile.fromString(
      jsonEncode(payload),
      filename: 'data.json',
      contentType: DioMediaType('application', 'json'),
    );
