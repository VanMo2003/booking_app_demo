import 'package:equatable/equatable.dart';

/// Deep link `bookingapp://…` — mở app từ email (qua trang `/app-links` của BE)
/// hoặc khi chạm vào thông báo đẩy.
sealed class AppLink extends Equatable {
  const AppLink();

  static const scheme = 'bookingapp';

  static AppLink? parse(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || uri.scheme != scheme) return null;
    // bookingapp://owner-status → host "owner-status";
    // bookingapp://owner-registrations/12 → host "owner-registrations", path "/12".
    final segments = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).toList();
    return switch (segments) {
      ['owner-status'] => const OwnerStatusLink(),
      ['notifications'] => const NotificationsLink(),
      ['owner-registrations', final id] when int.tryParse(id) != null =>
        OwnerRegistrationLink(int.parse(id)),
      ['chat', final id] when int.tryParse(id) != null => ChatLink(int.parse(id)),
      _ => null,
    };
  }

  @override
  List<Object?> get props => const [];
}

/// Trạng thái duyệt của chủ khách sạn đang đăng nhập.
final class OwnerStatusLink extends AppLink {
  const OwnerStatusLink();
}

final class NotificationsLink extends AppLink {
  const NotificationsLink();
}

/// Cuộc trò chuyện giữa khách và cơ sở (thông báo đẩy khi có tin nhắn mới).
final class ChatLink extends AppLink {
  const ChatLink(this.conversationId);

  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

/// Hồ sơ đăng ký chờ quản trị viên xét duyệt.
final class OwnerRegistrationLink extends AppLink {
  const OwnerRegistrationLink(this.chainId);

  final int chainId;

  @override
  List<Object?> get props => [chainId];
}
