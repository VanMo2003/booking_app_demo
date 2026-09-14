import 'package:url_launcher/url_launcher.dart';

/// Mở ứng dụng ngoài: gọi điện, trình duyệt.
abstract final class ExternalActions {
  static Future<bool> call(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return false;
    try {
      return await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openUrl(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      return false;
    }
  }
}
