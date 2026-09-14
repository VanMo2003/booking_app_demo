/// Chuỗi dùng chung toàn app.
///
/// Mọi câu chữ hiển thị nằm trong `core/text`; màn hình chỉ tham chiếu hằng số
/// nên đổi cách xưng hô, thuật ngữ chỉ cần sửa một chỗ.
abstract final class AppStrings {
  static const appName = 'Booking App';
  static const appTagline = 'Đặt phòng nhanh · Quản lý cơ sở gọn gàng';

  // Hành động
  static const save = 'Lưu';
  static const saveChanges = 'Lưu thay đổi';
  static const cancel = 'Huỷ';
  static const confirm = 'Xác nhận';
  static const delete = 'Xoá';
  static const edit = 'Sửa';
  static const add = 'Thêm';
  static const create = 'Tạo';
  static const close = 'Đóng';
  static const retry = 'Thử lại';
  static const back = 'Quay lại';
  static const next = 'Tiếp tục';
  static const done = 'Xong';
  static const search = 'Tìm';
  static const refresh = 'Làm mới';
  static const seeAll = 'Xem tất cả';
  static const apply = 'Áp dụng';
  static const change = 'Đổi';
  static const select = 'Chọn';
  static const call = 'Gọi';
  static const more = 'Thêm';
  static const loadMore = 'Tải thêm';
  static const login = 'Đăng nhập';
  static const register = 'Đăng ký';
  static const logout = 'Đăng xuất';
  static const exportExcel = 'Xuất Excel';

  // Trạng thái chung
  static const loading = 'Đang tải…';
  static const processing = 'Đang xử lý…';
  static const errorTitle = 'Không tải được dữ liệu';
  static const emptyTitle = 'Chưa có dữ liệu';
  static const notUpdated = 'Đang cập nhật';
  static const all = 'Tất cả';
  static const optional = 'Không bắt buộc';
  static const unknown = 'Không rõ';

  // Đơn vị
  static const perNight = '/đêm';
  static String nights(int n) => '$n đêm';
  static String guests(int n) => '$n khách';
  static String roomsCount(int n) => '$n phòng';
  static String bookingsCount(int n) => '$n đơn';
  static String itemsCount(int n) => '$n mục';

  // Phản hồi thao tác
  static const saved = 'Đã lưu';
  static const created = 'Đã tạo';
  static const updated = 'Đã cập nhật';
  static const deleted = 'Đã xoá';

  // Hộp thoại
  static const deleteTitle = 'Xoá dữ liệu?';
  static String deleteMessage(String name) =>
      'Xoá "$name"? Thao tác này không thể hoàn tác.';
  static const logoutTitle = 'Đăng xuất?';
  static const logoutMessage =
      'Bạn sẽ quay về trang chủ và vẫn xem được các cơ sở khi chưa đăng nhập.';

  // Giới thiệu
  static const aboutApp = 'Về ứng dụng';
  static const apiAddress = 'Địa chỉ máy chủ';
  static const version = 'Phiên bản 1.0.0';
}
