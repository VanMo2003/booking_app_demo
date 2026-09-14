/// Chuỗi cho các component trạng thái: lỗi hệ thống, mất mạng, dữ liệu trống.
abstract final class StateStrings {
  // Lỗi hệ thống — BE không phản hồi, máy chủ lỗi, lỗi không xác định
  static const systemErrorTitle = 'Hệ thống đang gặp sự cố';
  static const systemErrorMessage =
      'Không kết nối được máy chủ. Vui lòng thử lại sau ít phút.';

  // Lỗi yêu cầu — không có quyền, không tìm thấy, dữ liệu không hợp lệ
  static const requestErrorTitle = 'Không tải được dữ liệu';

  // Mất mạng
  static const offlineTitle = 'Mất kết nối mạng';
  static const offlineMessage =
      'Kiểm tra Wi-Fi hoặc dữ liệu di động. Dữ liệu sẽ tự tải lại khi có mạng trở lại.';
  static const reconnecting = 'Đã có mạng, đang tải lại…';

  // Dữ liệu trống
  static const emptyTitle = 'Chưa có dữ liệu';
  static const emptyMessage = 'Dữ liệu sẽ hiển thị ở đây khi được thêm.';

  // Nút
  static const reload = 'Tải lại';
  static const addNew = 'Thêm mới';
}
