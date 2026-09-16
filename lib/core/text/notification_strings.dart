/// Chuỗi cho hộp thông báo và thông báo đẩy.
abstract final class NotificationStrings {
  static const title = 'Thông báo';
  static const markAllRead = 'Đánh dấu đã đọc tất cả';
  static const allRead = 'Đã đánh dấu tất cả là đã đọc';
  static const empty = 'Chưa có thông báo';
  static const emptyHint = 'Kết quả xét duyệt và các cập nhật quan trọng sẽ hiện ở đây.';
  static const justNow = 'Vừa xong';
  static String minutesAgo(int n) => '$n phút trước';
  static String hoursAgo(int n) => '$n giờ trước';
  static String daysAgo(int n) => '$n ngày trước';
  static String unreadCount(int n) => '$n chưa đọc';
}
