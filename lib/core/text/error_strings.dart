/// Thông báo lỗi hiển thị cho người dùng, kèm bảng dịch thông báo tiếng Anh
/// mà BE trả trong trường `message`.
abstract final class ErrorStrings {
  static const serverUnreachable =
      'Không kết nối được máy chủ. Vui lòng thử lại sau ít phút.';
  static const offline =
      'Không có kết nối mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động.';
  static const timeout = 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.';
  static const cancelled = 'Yêu cầu đã bị huỷ.';
  static const unauthenticated =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const forbidden = 'Tài khoản không có quyền thực hiện thao tác này.';
  static const notFound = 'Không tìm thấy dữ liệu yêu cầu.';
  static const badRequest = 'Yêu cầu không hợp lệ.';
  static const server = 'Máy chủ gặp sự cố. Vui lòng thử lại sau.';
  static const badResponse = 'Dữ liệu máy chủ trả về không hợp lệ.';
  static const unknown = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  static const wrongCredentials = 'Sai tên đăng nhập hoặc mật khẩu.';
  static const fileTooLarge = 'Ảnh quá lớn. Hãy chọn ảnh dung lượng nhỏ hơn.';
  static const platformUnsupported =
      'Thiết bị này chưa hỗ trợ thao tác. Hãy thử trên ứng dụng di động.';
  static const usernameTaken = 'Tên đăng nhập đã tồn tại.';
  static const ownerNotApproved =
      'Tài khoản chủ khách sạn đang chờ quản trị viên duyệt.';
  static const adminReadOnly =
      'Quản trị viên chỉ được xem, không tạo hay sửa dữ liệu này.';

  /// Mẫu thông báo BE (so khớp không phân biệt hoa thường) → câu tiếng Việt.
  static const List<(String, String)> _known = [
    ('Incorrect account or password', wrongCredentials),
    ('Unauthenticated', unauthenticated),
    ('You do not have permission', forbidden),
    ('Account existed with username', usernameTaken),
    ('Hotel owner account is not approved yet', ownerNotApproved),
    ('Admin can only view this data', adminReadOnly),
    ('Registration is not waiting for review', 'Hồ sơ này đã được xử lý trước đó.'),
    (
      'Registration has already been approved',
      'Hồ sơ đã được duyệt nên không cần gửi lại.'
    ),
    (
      'Hotel owner accounts must register',
      'Chủ khách sạn tự đăng ký tài khoản đối tác trong ứng dụng.'
    ),
    ('Admin accounts cannot be created', forbidden),
    ('Account role cannot be changed', 'Không thể đổi vai trò của tài khoản.'),
    ('Only ADMIN can lock or unlock', forbidden),
    ('Only the account holder can change', forbidden),
    ('Hotel chain not found for this account', 'Tài khoản chưa có hồ sơ khách sạn.'),
    ('Account already owns a hotel chain', 'Tài khoản đã có hồ sơ khách sạn.'),
    (
      'is already booked',
      'Phòng đã có người đặt trong khoảng ngày này. Hãy chọn phòng hoặc ngày khác.'
    ),
    (
      'Checkout date must be after checkin date',
      'Ngày trả phòng phải sau ngày nhận phòng.'
    ),
    (
      'checkinDate và checkoutDate phải đi cùng nhau',
      'Cần chọn cả ngày nhận và ngày trả phòng.'
    ),
    ('Booking already completed', 'Đơn đã hoàn tất nên không thể thay đổi.'),
    ('Booking already cancelled', 'Đơn đã bị huỷ.'),
    ('does not use VN_PAY', 'Đơn này không chọn thanh toán VNPay.'),
    ('Booking already paid', 'Đơn đã được thanh toán.'),
    ('Booking is cancelled', 'Đơn đã bị huỷ nên không thể thanh toán.'),
    ('Booking is completed', 'Đơn đã hoàn tất nên không thể thanh toán.'),
    ('Room number already exists', 'Số phòng này đã có trong cơ sở.'),
    ('Amenity with this name already exists', 'Tiện ích cùng tên đã tồn tại.'),
    (
      'No unlinked walk-in profile',
      'Chưa có hồ sơ khách vãng lai nào với số điện thoại này.'
    ),
    ('already has a customer profile', 'Tài khoản đã có hồ sơ khách hàng.'),
    (
      'Only a customer account can claim',
      'Chỉ tài khoản khách hàng mới gắn được hồ sơ.'
    ),
    (
      'Staff accounts must be created',
      'Tài khoản nhân viên phải được tạo trong màn Nhân viên.'
    ),
    (
      'Create your customer profile before chatting',
      'Hãy tạo hồ sơ khách hàng trước khi nhắn tin.'
    ),
    (
      'AI assistant is unavailable',
      'Trợ lý AI đang bận hoặc chưa được bật trên máy chủ. Thử lại sau.'
    ),
    (
      'AI model is overloaded',
      'Máy chủ AI của Google đang quá tải. Thử lại sau ít phút.'
    ),
    (
      'AI quota exceeded',
      'Đã hết lượt AI miễn phí (theo phút hoặc theo ngày). Thử lại sau.'
    ),
    ('Too many AI requests', 'Bạn dùng AI hơi nhiều, thử lại sau vài phút nhé.'),
    ("The guest hasn't written anything yet", 'Khách chưa gửi tin nào để trả lời.'),
    ('Invalid signature', 'Kết quả thanh toán không hợp lệ.'),
    ('Upload failed', 'Tải ảnh lên thất bại. Vui lòng thử lại.'),
    ('File quá lớn', fileTooLarge),
    ('not found', notFound),
  ];

  static const Map<String, String> _fieldLabels = {
    'username': 'Tên đăng nhập',
    'password': 'Mật khẩu',
    'phoneNumber': 'Số điện thoại',
    'phone': 'Số điện thoại',
    'fullName': 'Họ tên',
    'name': 'Tên',
    'address': 'Địa chỉ',
    'category': 'Loại hình',
    'rooms': 'Phòng',
    'services': 'Dịch vụ',
    'paymentMethod': 'Phương thức thanh toán',
    'checkinDate': 'Ngày nhận phòng',
    'checkoutDate': 'Ngày trả phòng',
    'totalAmount': 'Tổng tiền',
    'hotelId': 'Cơ sở',
    'customerId': 'Khách hàng',
    'roomNumber': 'Số phòng',
    'price': 'Giá phòng',
    'unitPrice': 'Đơn giá',
    'capacity': 'Sức chứa',
    'roomTypeId': 'Loại phòng',
    'positionId': 'Chức vụ',
    'salary': 'Lương',
    'dateOfBirth': 'Ngày sinh',
    'employeeId': 'Nhân viên',
    'month': 'Tháng',
    'totalSalary': 'Tổng lương',
    'rating': 'Điểm đánh giá',
    'accountId': 'Tài khoản',
    'role': 'Vai trò',
    'ownerName': 'Họ tên người đại diện',
    'email': 'Email',
    'hotelName': 'Tên khách sạn',
    'description': 'Giới thiệu',
    'reason': 'Lý do',
    'content': 'Nội dung tin nhắn',
    'query': 'Câu tìm kiếm',
  };

  /// Chuyển thông báo thô của BE thành câu tiếng Việt cho người dùng.
  static String translate(String? raw, {int? code, int? status}) {
    var message = (raw ?? '').trim();
    const unexpectedPrefix = 'Unexpected error:';
    if (message.startsWith(unexpectedPrefix)) {
      message = message.substring(unexpectedPrefix.length).trim();
    }
    if (message.isEmpty) return byStatus(status, code);

    final lower = message.toLowerCase();
    for (final (pattern, translated) in _known) {
      if (lower.contains(pattern.toLowerCase())) return translated;
    }
    if (code == 402) return _validation(message);
    if (_hasVietnameseLetters(message)) return message;
    if ((status ?? 0) >= 500) return server;
    return message;
  }

  static String byStatus(int? status, [int? code]) {
    if (status == 401 || code == 1001) return unauthenticated;
    if (status == 403 || code == 1002) return forbidden;
    if (status == 404) return notFound;
    if (status == 413) return fileTooLarge;
    if (status == 400) return badRequest;
    if ((status ?? 0) >= 500) return server;
    return unknown;
  }

  static String _validation(String message) {
    final separator = message.indexOf(':');
    if (separator <= 0) return message;
    final field = message.substring(0, separator).trim();
    final detail = message.substring(separator + 1).trim().toLowerCase();
    final label = _fieldLabels[field] ?? field;
    if (detail.contains('must not be')) return '$label không được để trống.';
    if (detail.contains('must match') || detail.contains('invalid')) {
      return '$label không đúng định dạng.';
    }
    if (detail.contains('greater than') || detail.contains('must be at least')) {
      return '$label chưa đạt giá trị tối thiểu.';
    }
    if (detail.contains('less than') || detail.contains('must be at most')) {
      return '$label vượt quá giá trị cho phép.';
    }
    return '$label không hợp lệ.';
  }

  static bool _hasVietnameseLetters(String text) =>
      RegExp(r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ]',
              caseSensitive: false)
          .hasMatch(text);
}
