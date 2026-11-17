import 'package:equatable/equatable.dart';

/// Máy chủ có bật AI hay không, và dịch được sang những ngôn ngữ nào.
/// Danh sách ngôn ngữ lấy từ máy chủ chứ không khai lại trong app, để hai bên không lệch nhau.
class AiStatus extends Equatable {
  const AiStatus({required this.enabled, this.languages = const {}});

  final bool enabled;

  /// Mã ngôn ngữ -> tên hiển thị, ví dụ `{'en': 'English'}`.
  final Map<String, String> languages;

  @override
  List<Object?> get props => [enabled, languages];
}
