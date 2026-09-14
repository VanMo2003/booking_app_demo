/// Chuỗi cho phần khách: trang chủ, tìm kiếm, cơ sở, phòng, yêu thích, tài khoản.
abstract final class ExploreStrings {
  // Thanh điều hướng
  static const tabExplore = 'Khám phá';
  static const tabBookings = 'Đơn của tôi';
  static const tabFavorites = 'Yêu thích';
  static const tabAccount = 'Tài khoản';

  // Trang chủ
  static const greetingGuest = 'Xin chào!';
  static String greetingName(String name) => 'Xin chào, $name';
  static const homeHeadline = 'Hôm nay bạn muốn nghỉ ở đâu?';
  static const checkin = 'Nhận phòng';
  static const checkout = 'Trả phòng';
  static const findAvailable = 'Tìm phòng trống';
  static const categories = 'Loại hình';
  static const allBranches = 'Tất cả cơ sở';
  static String branchesCount(int n) => '$n cơ sở';
  static const branchesEmpty = 'Chưa có cơ sở nào';
  static const branchesEmptyCategory = 'Không có cơ sở thuộc loại hình này';

  // Kết quả tìm kiếm
  static const searchTitle = 'Phòng trống';
  static String searchSummary(int available, int total) =>
      '$available/$total cơ sở còn phòng';
  static const searchEmpty = 'Không có cơ sở nào';

  // Chi tiết cơ sở
  static const about = 'Giới thiệu';
  static const amenities = 'Tiện ích';
  static const services = 'Dịch vụ thêm';
  static const rooms = 'Phòng';
  static const pickDates = 'Chọn ngày';
  static const pickDatesHint = 'Chọn ngày để xem phòng còn trống';
  static String availableRooms(int n) => '$n phòng trống';
  static const noRooms = 'Cơ sở chưa có phòng';
  static const noAvailableRooms = 'Không còn phòng trống cho ngày đã chọn';
  static const bookNow = 'Đặt phòng';
  static const book = 'Đặt';
  static const contact = 'Liên hệ';
  static const branchClosed = 'Cơ sở đang tạm đóng, chưa nhận đặt phòng';
  static const readMore = 'Xem thêm';
  static const readLess = 'Thu gọn';

  // Chi tiết phòng
  static const roomDetailTitle = 'Chi tiết phòng';
  static String roomTitle(String number) => 'Phòng $number';
  static String capacity(int n) => 'Tối đa $n khách';
  static const roomAmenities = 'Tiện ích trong phòng';
  static const availability = 'Tình trạng phòng';
  static const roomAvailable = 'Phòng còn trống cho ngày đã chọn';
  static const roomNotAvailable = 'Phòng không trống trong khoảng ngày này';
  static const bookThisRoom = 'Đặt phòng này';
  static String totalForNights(int nights) => 'Tổng $nights đêm';

  // Yêu thích
  static const favoritesTitle = 'Yêu thích';
  static const favoritesEmpty = 'Chưa có cơ sở yêu thích';
  static const favoritesEmptyHint =
      'Nhấn biểu tượng trái tim ở một cơ sở để lưu lại xem sau.';
  static const favoriteAdded = 'Đã lưu vào yêu thích';
  static const favoriteRemoved = 'Đã bỏ khỏi yêu thích';

  // Tài khoản & hồ sơ
  static const accountTitle = 'Tài khoản';
  static const guestTitle = 'Bạn chưa đăng nhập';
  static const guestSubtitle =
      'Đăng nhập để đặt phòng, lưu yêu thích và theo dõi đơn.';
  static const profileTitle = 'Hồ sơ';
  static const editProfile = 'Sửa hồ sơ';
  static const profileSaved = 'Đã lưu hồ sơ';
  static const fullName = 'Họ và tên';
  static const phone = 'Số điện thoại';
  static const gender = 'Giới tính';
  static const hometown = 'Quê quán';
  static const username = 'Tên đăng nhập';
  static const groupProfile = 'Hồ sơ';
  static const groupBooking = 'Đặt phòng';
  static const passwordChangeUnavailable =
      'Đổi mật khẩu tạm ẩn cho tới khi máy chủ mã hoá mật khẩu mới.';
}
