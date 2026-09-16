import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'app_link.dart';

/// Nhận link `bookingapp://…` mở app, gồm cả link đã mở app lúc khởi động.
@lazySingleton
class DeepLinkService {
  AppLinks? _appLinks;

  Stream<String> get links {
    // Bản web không có custom scheme — link email mở trang web của BE.
    if (kIsWeb) return const Stream.empty();
    final appLinks = _appLinks ??= AppLinks();
    return appLinks.uriLinkStream
        .map((uri) => uri.toString())
        .where((link) => link.startsWith('${AppLink.scheme}:'))
        .handleError((Object _) {});
  }
}
