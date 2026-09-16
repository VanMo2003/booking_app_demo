/// Chuỗi cho luồng đối tác: đăng ký chủ khách sạn, chờ duyệt, xét duyệt của
/// quản trị viên.
abstract final class PartnerStrings {
  // Lối vào ở tab Tài khoản
  static const groupPartner = 'Dành cho đối tác';
  static const becomeOwner = 'Đăng ký chủ khách sạn';
  static const becomeOwnerHint = 'Đưa khách sạn của bạn lên Booking App';

  // Đăng ký
  static const registerHeadline = 'Trở thành đối tác';
  static const registerSubtitle =
      'Tạo tài khoản chủ khách sạn và gửi thông tin khách sạn. Quản trị viên duyệt hồ sơ trước khi bạn bắt đầu nhận khách.';
  static const stepAccount = 'Tài khoản';
  static const stepHotel = 'Khách sạn';
  static const accountTitle = 'Tài khoản đăng nhập';
  static const accountHint =
      'Bạn dùng tài khoản này để quản lý khách sạn sau khi hồ sơ được duyệt.';
  static const hotelTitle = 'Thông tin khách sạn';
  static const hotelHint = 'Thông tin rõ ràng giúp hồ sơ được duyệt nhanh hơn.';
  static const hotelName = 'Tên khách sạn';
  static const hotelAddress = 'Địa chỉ khách sạn';
  static const hotelPhone = 'Số điện thoại khách sạn';
  static const ownerName = 'Họ tên người đại diện';
  static const email = 'Email nhận kết quả duyệt';
  static const description = 'Giới thiệu khách sạn';
  static const submit = 'Gửi đăng ký';
  static const submitted = 'Đã gửi hồ sơ. Đang chờ quản trị viên duyệt.';
  static const haveAccount = 'Đã có tài khoản chủ khách sạn?';
  static const registeredLoginFailed =
      'Đã gửi hồ sơ nhưng chưa đăng nhập được. Hãy đăng nhập bằng tài khoản vừa tạo để theo dõi trạng thái.';

  // Màn chờ duyệt / bị từ chối
  static const pendingTitle = 'Tài khoản chủ khách sạn của bạn đang chờ xét duyệt';
  static String pendingMessage(String email) => email.isEmpty
      ? 'Quản trị viên sẽ xem hồ sơ và báo kết quả qua thông báo trong ứng dụng.'
      : 'Quản trị viên sẽ xem hồ sơ và báo kết quả qua thông báo trong ứng dụng và email $email.';
  static const rejectedTitle = 'Hồ sơ chưa được duyệt';
  static const rejectedMessage =
      'Cập nhật thông tin theo góp ý bên dưới rồi gửi lại để được xét duyệt.';
  static const rejectionReason = 'Lý do từ chối';
  static const previousRejection = 'Lần trước bị từ chối vì';
  static const approvedToast =
      'Hồ sơ đã được duyệt. Bắt đầu thêm quản lý, phòng, tiện ích và dịch vụ!';
  static const stepSubmitted = 'Gửi hồ sơ';
  static const stepReview = 'Quản trị viên xét duyệt';
  static const stepReviewHint = 'Thường trong 1–2 ngày làm việc';
  static const stepStart = 'Bắt đầu kinh doanh';
  static const stepStartHint = 'Thêm quản lý, phòng, tiện ích và dịch vụ';
  static const submittedDetails = 'Hồ sơ đã gửi';
  static const checkStatus = 'Kiểm tra trạng thái';
  static const autoCheck = 'Ứng dụng tự kiểm tra lại mỗi 30 giây và khi bạn mở lại.';
  static String checkedAt(String time) => 'Đã kiểm tra lúc $time · tự kiểm tra lại mỗi 30 giây';
  static const editProfile = 'Sửa hồ sơ';
  static const resubmit = 'Cập nhật & gửi lại';
  static const profileTitle = 'Cập nhật hồ sơ';
  static const resubmitAction = 'Gửi lại hồ sơ';
  static const saveProfile = 'Lưu hồ sơ';
  static const resubmitted = 'Đã gửi lại hồ sơ, đang chờ xét duyệt';
  static const profileSaved = 'Đã cập nhật hồ sơ';

  // Nhãn ngắn trong thẻ thông tin
  static const labelHotel = 'Khách sạn';
  static const labelAddress = 'Địa chỉ';
  static const labelPhone = 'Điện thoại';
  static const labelOwner = 'Người đại diện';
  static const labelEmail = 'Email';
  static const labelAccount = 'Tài khoản';
  static const labelSubmitted = 'Gửi lúc';
  static const labelReviewed = 'Xử lý lúc';
  static const labelAbout = 'Giới thiệu';

  // Quản trị viên xét duyệt
  static const tabApprovals = 'Xét duyệt';
  static const approvalsTitle = 'Xét duyệt chủ khách sạn';
  static const approvalsEmptyPending = 'Không có hồ sơ chờ duyệt';
  static const approvalsEmptyPendingHint =
      'Hồ sơ đăng ký chủ khách sạn mới sẽ xuất hiện tại đây.';
  static const approvalsEmpty = 'Chưa có hồ sơ nào';
  static String submittedOn(String time) => 'Gửi lúc $time';
  static String reviewedOn(String time) => 'Xử lý lúc $time';
  static const resubmittedTag = 'Đã gửi lại';
  static const detailTitle = 'Hồ sơ đăng ký';
  static const hotelSection = 'Khách sạn';
  static const ownerSection = 'Người đại diện';
  static const approve = 'Duyệt';
  static const reject = 'Từ chối';
  static const approveTitle = 'Duyệt hồ sơ này?';
  static String approveMessage(String hotel) =>
      '$hotel sẽ được mở khoá để thêm quản lý, phòng, tiện ích và dịch vụ. Chủ khách sạn nhận thông báo trong ứng dụng và email.';
  static const approvedDone = 'Đã duyệt hồ sơ';
  static const rejectTitle = 'Từ chối hồ sơ';
  static const rejectHint =
      'Lý do được gửi cho chủ khách sạn qua thông báo và email để họ sửa rồi gửi lại.';
  static const rejectReason = 'Lý do từ chối';
  static const rejectReasonRequired = 'Nhập lý do để chủ khách sạn biết cần sửa gì';
  static const rejectSubmit = 'Gửi từ chối';
  static const rejectedDone = 'Đã từ chối hồ sơ';
  static const quickReasons = [
    'Số điện thoại không liên lạc được',
    'Địa chỉ khách sạn chưa rõ ràng',
    'Tên khách sạn chưa phù hợp',
  ];

  // Tổng quan quản trị
  static String pendingCount(int n) => '$n hồ sơ chờ duyệt';
  static const pendingCountHint = 'Chủ khách sạn đang chờ để mở cơ sở, thêm phòng và dịch vụ.';
  static const noPending = 'Không có hồ sơ chờ duyệt';
  static const noPendingHint = 'Hồ sơ chủ khách sạn mới sẽ báo về thông báo của bạn.';
  static const reviewNow = 'Xét duyệt ngay';
}
