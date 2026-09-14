abstract final class AppConstants {
  static const int pageSize = 10;

  /// Kích thước trang khi cần tải gần như toàn bộ (phòng của cơ sở, danh sách cơ sở).
  static const int bulkPageSize = 100;

  static const int maxDailyReportDays = 92;
  static const int topCustomersLimit = 10;

  static const List<String> hotelCategories = [
    'Khách sạn',
    'Resort',
    'Homestay',
    'Căn hộ dịch vụ',
    'Nhà nghỉ',
    'Biệt thự',
  ];

  static const List<String> genders = ['Nam', 'Nữ', 'Khác'];

  static const List<String> provinces = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bạc Liêu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Dương',
    'Bình Định',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cao Bằng',
    'Cần Thơ',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hồ Chí Minh',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lạng Sơn',
    'Lào Cai',
    'Lâm Đồng',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];
}

abstract final class StorageKeys {
  static const session = 'auth.session';
  static const favoritesPrefix = 'favorites.';
  static const reviewedPrefix = 'reviewed_bookings.';
  static const lastBranchPrefix = 'last_branch.';
  static const createdManagersPrefix = 'created_managers.';
}
