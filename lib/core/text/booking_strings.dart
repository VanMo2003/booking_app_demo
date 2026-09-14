/// Chuỗi cho luồng đặt phòng, đơn, thanh toán, đánh giá, quầy lễ tân.
abstract final class BookingStrings {
  // Tạo đơn (khách)
  static const createTitle = 'Đặt phòng';
  static const stepStay = 'Ngày lưu trú';
  static const stepRooms = 'Chọn phòng';
  static const stepServices = 'Dịch vụ thêm';
  static const stepPayment = 'Thanh toán';
  static const stepNote = 'Ghi chú cho cơ sở';
  static const noteHint = 'Ví dụ: nhận phòng muộn khoảng 21h';
  static const noRoomsForDates = 'Không còn phòng trống trong khoảng ngày này';
  static const pickAtLeastOneRoom = 'Chọn ít nhất một phòng';
  static const noServices = 'Cơ sở chưa có dịch vụ thêm';
  static const totalLabel = 'Tổng thanh toán';
  static String roomsLine(int rooms, int nights) =>
      '$rooms phòng × $nights đêm';
  static String servicesLine(int count) => '$count dịch vụ';
  static const roomsSubtotal = 'Tiền phòng';
  static const servicesSubtotal = 'Tiền dịch vụ';
  static const submit = 'Xác nhận đặt phòng';
  static const created = 'Đặt phòng thành công';

  // Danh sách đơn của khách
  static const myBookingsTitle = 'Đơn của tôi';
  static const bookingsEmpty = 'Chưa có đơn đặt phòng';
  static const bookingsEmptyHint =
      'Tìm một cơ sở phù hợp và đặt phòng đầu tiên của bạn.';
  static const bookingsEmptyStatus = 'Không có đơn nào ở trạng thái này';
  static const exploreNow = 'Khám phá cơ sở';

  // Chi tiết đơn
  static String code(int id) => 'Đơn #$id';
  static const stay = 'Thời gian lưu trú';
  static const roomsBooked = 'Phòng đã đặt';
  static const servicesBooked = 'Dịch vụ đã chọn';
  static const customer = 'Khách hàng';
  static const branch = 'Cơ sở';
  static const payment = 'Thanh toán';
  static const paymentMethod = 'Phương thức';
  static const paymentStatus = 'Trạng thái';
  static const paidAt = 'Thanh toán lúc';
  static const total = 'Tổng tiền';
  static const note = 'Ghi chú';
  static const createdAt = 'Tạo lúc';
  static const createdAtDesk = 'Tạo tại quầy';
  static String payExpiresIn(String remaining) =>
      'Giữ đơn thêm $remaining để thanh toán';
  static const payExpired =
      'Đã hết thời gian giữ đơn — bạn vẫn có thể thanh toán lại';
  static const walkInGuest = 'Khách vãng lai';

  // Hành động trên đơn
  static const cancelBooking = 'Huỷ đơn';
  static const cancelTitle = 'Huỷ đơn đặt phòng?';
  static const cancelMessage =
      'Phòng sẽ được mở lại cho khách khác. Thao tác không thể hoàn tác.';
  static const canceled = 'Đã huỷ đơn';
  static const payNow = 'Thanh toán VNPay';
  static const payAgain = 'Thanh toán lại';
  static const review = 'Đánh giá';
  static const reviewed = 'Đã đánh giá';
  static const confirmBooking = 'Xác nhận đơn';
  static const confirmed = 'Đã xác nhận đơn';
  static const markPaid = 'Đã thu tiền';
  static const markPaidTitle = 'Ghi nhận đã thu tiền?';
  static const markPaidMessage =
      'Dùng khi khách trả tiền mặt hoặc bạn đã nhận được chuyển khoản.';
  static const markedPaid = 'Đã ghi nhận thanh toán';
  static const completeBooking = 'Hoàn tất';
  static const completeTitle = 'Hoàn tất đơn (khách trả phòng)?';
  static const completeMessage =
      'Đơn hoàn tất sẽ được tính vào doanh thu và không thể huỷ.';
  static const completeUnpaidWarning =
      'Đơn chưa ghi nhận thanh toán. Hãy thu tiền trước khi hoàn tất.';
  static const completed = 'Đã hoàn tất đơn';
  static const editBooking = 'Sửa đơn';
  static const deleteBooking = 'Xoá đơn';
  static const deleted = 'Đã xoá đơn';
  static const callBranch = 'Gọi cơ sở';
  static const callGuest = 'Gọi khách';

  // Thanh toán VNPay
  static const paymentTitle = 'Thanh toán VNPay';
  static const paymentPreparing = 'Đang tạo link thanh toán…';
  static const paymentVerifying = 'Đang xác nhận kết quả thanh toán…';
  static const paymentSuccessTitle = 'Thanh toán thành công';
  static const paymentSuccessMessage =
      'Đơn đã được ghi nhận thanh toán. Hẹn gặp bạn tại cơ sở!';
  static const paymentFailedTitle = 'Thanh toán chưa thành công';
  static const paymentFailedMessage =
      'Giao dịch bị huỷ hoặc thất bại. Bạn có thể thử lại trong thời gian giữ đơn.';
  static const paymentExpiredTitle = 'Hết thời gian thanh toán';
  static const paymentExpiredMessage =
      'Link thanh toán đã hết hạn. Tạo lại link để tiếp tục.';
  static const paymentClosed = 'Bạn đã đóng trang thanh toán';
  static const paymentWebTitle = 'Mở VNPay trong tab mới';
  static const paymentWebMessage =
      'Trình duyệt không nhận kết quả VNPay tự động. Thanh toán xong, quay lại đây và bấm Kiểm tra trạng thái.';
  static const checkStatus = 'Kiểm tra trạng thái';
  static const viewBooking = 'Xem đơn';

  // Đánh giá
  static const reviewTitle = 'Đánh giá kỳ nghỉ';
  static const reviewHeadline = 'Kỳ nghỉ của bạn thế nào?';
  static const reviewComment = 'Chia sẻ trải nghiệm';
  static const reviewCommentHint = 'Phòng ốc, dịch vụ, nhân viên…';
  static const reviewSubmit = 'Gửi đánh giá';
  static const reviewThanks = 'Cảm ơn bạn đã đánh giá!';
  static const ratingLabels = [
    'Rất tệ',
    'Chưa tốt',
    'Bình thường',
    'Tốt',
    'Tuyệt vời',
  ];

  // Quầy lễ tân
  static const deskTitle = 'Quầy lễ tân';
  static const filterArrivals = 'Đến hôm nay';
  static const filterDepartures = 'Trả phòng hôm nay';
  static const filterInHouse = 'Đang lưu trú';
  static const filterPending = 'Chờ xác nhận';
  static const filterAll = 'Tất cả';
  static const deskSearchHint = 'Tên khách, số điện thoại hoặc mã đơn';
  static const deskEmpty = 'Không có đơn phù hợp';
  static const deskEmptyHint = 'Khách đến trực tiếp? Tạo đơn tại quầy ngay.';
  static const walkInAction = 'Đặt tại quầy';

  // Đặt tại quầy
  static const walkInTitle = 'Đặt phòng tại quầy';
  static const stepGuest = 'Khách';
  static const stepDatesRooms = 'Ngày & phòng';
  static const stepExtras = 'Dịch vụ & thanh toán';
  static const stepConfirm = 'Xác nhận';
  static const guestPhone = 'Số điện thoại khách';
  static const guestPhoneHint = 'Nhập 10 số để tìm hồ sơ có sẵn';
  static const findGuest = 'Tìm hồ sơ';
  static const guestFound = 'Hồ sơ đã có trong hệ thống';
  static const useGuest = 'Chọn khách này';
  static const guestNotFound =
      'Chưa có hồ sơ với số này — tạo hồ sơ khách vãng lai bên dưới.';
  static const createGuest = 'Tạo hồ sơ và chọn';
  static const selectedGuest = 'Khách đã chọn';
  static const changeGuest = 'Đổi khách';
  static const guestRequired = 'Chọn hoặc tạo hồ sơ khách trước';
  static const createBooking = 'Tạo đơn';
  static String bookingCreated(int id) => 'Đã tạo đơn #$id';
  static const afterCreateMessage = 'Bạn muốn xử lý đơn này thế nào?';
  static const confirmAndCollect = 'Xác nhận và ghi nhận đã thu tiền';
  static const confirmOnly = 'Chỉ xác nhận đơn';
  static const later = 'Để sau';

  // Sửa đơn
  static String editTitle(int id) => 'Sửa đơn #$id';
  static const editSaved = 'Đã cập nhật đơn';
  static const keepCurrentRooms = 'Phòng đang thuộc đơn này vẫn được giữ.';
}
