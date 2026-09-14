import '../text/error_strings.dart';
import 'app_exception.dart';
import 'json_reader.dart';
import 'paged.dart';

/// Khung `{success, code, message?, data?}` của mọi API JSON phía BE.
class ApiResponse {
  const ApiResponse({
    required this.success,
    required this.code,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        success: json['success'] == true,
        code: (json['code'] as num?)?.toInt() ?? 0,
        message: json['message'] as String?,
        data: json['data'],
      );

  final bool success;
  final int code;
  final String? message;
  final Object? data;

  /// Vài API (VNPay) trả HTTP 200 nhưng `success: false` — coi như lỗi.
  void ensureSuccess() {
    if (!success) {
      throw AppException(
        ErrorStrings.translate(message, code: code),
        code: code,
        kind: AppException.kindOf(code: code),
      );
    }
  }

  Json get json {
    ensureSuccess();
    final value = data;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const AppException(ErrorStrings.badResponse);
  }

  List<Json> get jsonList {
    ensureSuccess();
    final value = data;
    if (value == null) return const [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const AppException(ErrorStrings.badResponse);
  }

  T parse<T>(T Function(Json json) mapper) => mapper(json);

  List<T> parseList<T>(T Function(Json json) mapper) =>
      jsonList.map(mapper).toList();

  Paged<T> parsePage<T>(T Function(Json json) mapper) =>
      Paged.fromJson(json, mapper);

  List<String> get stringList {
    ensureSuccess();
    final value = data;
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  String get text {
    ensureSuccess();
    return data?.toString() ?? '';
  }
}
