/// Chuỗi cho thực đơn món ăn của cơ sở: quản lý (chủ khách sạn, quản lý) và
/// phần khách xem.
abstract final class MenuStrings {
  // Chung
  static const title = 'Thực đơn';
  static String dishesCount(int n) => '$n món';
  static const available = 'Còn phục vụ';
  static const unavailable = 'Tạm hết';
  static const all = 'Tất cả';

  // Quản lý
  static const addDish = 'Thêm món';
  static const editDish = 'Sửa món';
  static const empty = 'Chưa có món nào';
  static const emptyHint = 'Thêm món để khách xem được thực đơn của cơ sở.';
  static const readOnlyNotice =
      'Chế độ xem — chỉ chủ khách sạn và quản lý cơ sở được thêm, sửa, xoá món.';
  static const saved = 'Đã lưu món';
  static const deleted = 'Đã xoá món';
  static const markedAvailable = 'Món đã phục vụ trở lại';
  static const markedUnavailable = 'Đã đánh dấu tạm hết';
  static const markAvailable = 'Phục vụ trở lại';
  static const markUnavailable = 'Đánh dấu tạm hết';

  // Biểu mẫu
  static const dishInfo = 'Thông tin món';
  static const name = 'Tên món';
  static const category = 'Nhóm món';
  static const price = 'Giá (₫)';
  static const description = 'Mô tả';
  static const descriptionHint = 'Nguyên liệu, khẩu phần, hương vị…';
  static const photo = 'Ảnh món';
  static const photoHint = 'Ảnh vuông hoặc ngang, món ăn chiếm phần lớn khung hình.';
  static const availableHint = 'Tắt khi bếp tạm hết — món vẫn hiện trên thực đơn.';

  // Phía khách
  static const viewMenu = 'Xem thực đơn';
  static const menuSubtitle = 'Món ăn và đồ uống phục vụ tại cơ sở';
  static const guestEmpty = 'Cơ sở chưa cập nhật thực đơn';
}
