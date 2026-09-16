import 'package:firebase_core/firebase_core.dart';

/// Cấu hình Firebase truyền lúc build bằng `--dart-define`. Trên Android có thể
/// bỏ qua các biến này và đặt `android/app/google-services.json` thay thế.
abstract final class FirebaseConfig {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static FirebaseOptions? get options {
    if (_apiKey.isEmpty || _appId.isEmpty || _senderId.isEmpty || _projectId.isEmpty) {
      return null;
    }
    return const FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
    );
  }
}
