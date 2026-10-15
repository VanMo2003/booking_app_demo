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

  // Nhận thông báo khi tắt app (Android)
  static const setupTitle = 'Nhận thông báo khi tắt app';
  static const setupReady = 'Đã sẵn sàng — vẫn nhận thông báo khi đã vuốt tắt app';
  static const setupNeeded = 'Cần bật thêm quyền để nhận thông báo khi tắt app';
  static const setupIntro =
      'Để nhận tin nhắn và thông báo đơn khi đã vuốt tắt app, máy cần cho phép đủ các mục dưới đây. '
      'Bấm từng nút, bật quyền trong trang cài đặt rồi quay lại — trạng thái tự cập nhật.';
  static String setupBrandHint(String brand) =>
      'Máy $brand chặn thông báo của app đã tắt nếu chưa bật "Tự khởi chạy". Trong trang cài đặt, '
      'tìm Booking App và bật công tắc; mục "Tiết kiệm pin" chọn "Không hạn chế".';
  static const itemNotifications = 'Cho phép hiện thông báo';
  static const itemNotificationsHint = 'Quyền hiện thông báo của app.';
  static const itemAutoStart = 'Tự khởi chạy';
  static const itemAutoStartHint =
      'Cho phép máy mở app ngầm để hiện thông báo khi app đã tắt (Xiaomi, Oppo, Vivo, Huawei…).';
  static const itemAutoStartUnknown = 'Máy không cho đọc trạng thái — hãy mở và kiểm tra công tắc đã bật.';
  static const itemBattery = 'Không giới hạn pin';
  static const itemBatteryHint = 'Không để chế độ tiết kiệm pin dừng app khi chạy ngầm.';
  static const statusOn = 'Đã bật';
  static const statusOff = 'Chưa bật';
  static const statusCheck = 'Cần kiểm tra';
  static const openSettings = 'Mở cài đặt';
  static const enable = 'Bật';
  static const allow = 'Cho phép';
  static const notAndroid = 'Chỉ cần thiết lập trên điện thoại Android.';
  static const testTitle = 'Thử nhận thông báo khi tắt app';
  static const testHint =
      'Bấm gửi, rồi vuốt tắt app ngay. Khoảng 10 giây sau máy phải hiện "Thông báo thử".';
  static const testSend = 'Gửi thông báo thử';
  static String testSent(int seconds) => 'Thông báo thử sẽ tới sau $seconds giây — vuốt tắt app ngay';
  static const testServerOff =
      'Máy chủ chưa bật thông báo đẩy (thiếu FIREBASE_CREDENTIALS) — xem README của BE.';
  static const testNoDevice = 'Máy chưa đăng ký nhận thông báo — đăng xuất rồi đăng nhập lại.';
  static const promptTitle = 'Bật nhận thông báo khi tắt app?';
  static const promptMessage =
      'Máy đang chặn thông báo khi app đã tắt, nên bạn có thể lỡ tin nhắn và đơn mới. '
      'Mất khoảng 1 phút để bật.';
  static const promptConfirm = 'Thiết lập ngay';
  static const promptLater = 'Để sau';
}
