/// Chuỗi cho tour tham quan của cơ sở: quản lý (chủ khách sạn, quản lý) và phần khách xem.
abstract final class TourStrings {
  static const title = 'Tour tham quan';
  static String toursCount(int n) => '$n tour';
  static const running = 'Đang nhận khách';
  static const paused = 'Tạm ngừng';
  static const perGuest = '/khách';

  // Quản lý
  static const addTour = 'Thêm tour';
  static const editTour = 'Sửa tour';
  static const empty = 'Chưa có tour nào';
  static const emptyHint =
      'Thêm tour để khách tham khảo khi xem cơ sở, và để trợ lý AI gợi ý tour cho khách trong tin nhắn.';
  static const readOnlyNotice =
      'Chế độ xem — chỉ chủ khách sạn và quản lý cơ sở được thêm, sửa, xoá tour.';
  static const saved = 'Đã lưu tour';
  static const deleted = 'Đã xoá tour';
  static const markPaused = 'Tạm ngừng tour';
  static const markRunning = 'Mở lại tour';
  static const markedPaused = 'Đã tạm ngừng tour';
  static const markedRunning = 'Tour đã mở lại';

  // Biểu mẫu
  static const photo = 'Ảnh tour';
  static const photoHint = 'Ảnh phong cảnh hoặc hoạt động nổi bật của tour, khổ ngang.';
  static const tourInfo = 'Thông tin tour';
  static const name = 'Tên tour';
  static const nameHint = 'VD: Food tour phố cổ buổi tối';
  static const price = 'Giá mỗi khách (₫)';
  static const pricePerGuest = 'Giá mỗi khách';
  static const duration = 'Thời lượng';
  static const durationHint = 'VD: 4 giờ, 1 ngày, 2 ngày 1 đêm';
  static const departure = 'Khởi hành';
  static const departureHint = 'VD: 8:00 hằng ngày';
  static const includes = 'Giá đã gồm';
  static const includesHint = 'Xe đưa đón, vé tham quan, hướng dẫn viên…';
  static const maxGuests = 'Số chỗ mỗi chuyến';
  static const maxGuestsHint = 'Tổng khách các đơn cùng ngày; để trống nếu không giới hạn';
  static const description = 'Mô tả, lịch trình';
  static const descriptionHint = 'Điểm đến, hoạt động, lưu ý cho khách…';
  static const roomsSection = 'Phòng kèm tour';
  static const roomsHint =
      'Đặt tour là đặt luôn phòng ở từ ngày đi tour. Chọn các phòng của gói (phòng rẻ hay phòng cao cấp) — '
      'khách chọn một trong các phòng còn trống đêm đó. Không chọn phòng nào thì chỉ bán tour.';
  static const stayNights = 'Số đêm ở';
  static const stayNightsHint = 'Tính từ ngày đi tour';
  static String roomsSelected(int n) => n == 0 ? 'Chưa chọn phòng — chỉ bán tour' : 'Đã chọn $n phòng';
  static const roomsLoadFailed = 'Không tải được danh sách phòng của cơ sở.';
  static const availableHint =
      'Tắt khi tạm ngừng — tour vẫn hiện nhưng khách thấy "Tạm ngừng" và trợ lý AI không gợi ý.';

  // Phía khách
  static const sectionSubtitle = 'Khách sạn tổ chức · đặt qua tin nhắn';
  static String viewAll(int n) => 'Xem cả $n tour';
  static String maxGuestsValue(int n) => 'Tối đa $n khách mỗi chuyến';
  static const ask = 'Nhắn khách sạn để đặt tour';
  static const askShort = 'Hỏi khách sạn';
  static const book = 'Đặt tour';
  static const perNight = '/đêm';
  static String stayInfo(int nights) => 'Ở $nights đêm từ ngày đi tour — chọn một phòng còn trống khi đặt:';
  static const withoutRooms = 'Tour này không kèm phòng.';
  static String capacity(int n) => '$n người';
  static String askDraft(String name) => 'Mình muốn đặt tour "$name" ngày ';
  static const bookingNote =
      'Bấm "Đặt tour" để chọn ngày và phòng, hoặc nhắn khách sạn: trợ lý gửi tóm tắt, bạn nhắn "Đồng ý" '
      'là đơn được tạo. Khách sạn xác nhận sau, thanh toán tại khách sạn.';
  static const guestEmpty = 'Cơ sở chưa có tour';
}

/// Đơn tour — khách theo dõi đơn của mình, đội ngũ cơ sở xác nhận / hoàn tất / huỷ.
abstract final class TourBookingStrings {
  static const myTitle = 'Đơn tour của tôi';
  static const branchTitle = 'Đơn tour';
  static const entry = 'Đơn tour';
  static String code(int id) => 'Đơn tour #$id';
  static String guests(int n) => '$n khách';
  static const empty = 'Chưa có đơn tour';
  static const emptyMineHint =
      'Mở trang khách sạn, chọn tour rồi nhắn khách sạn ngày đi và số khách để đặt.';
  static const emptyBranchHint =
      'Đơn tour khách đặt (kể cả qua trợ lý AI trong tin nhắn) sẽ hiện ở đây và được báo cho đội ngũ.';
  static const emptyStatus = 'Không có đơn ở trạng thái này';

  // Đặt tour trong ứng dụng
  static const formTitle = 'Đặt tour';
  static const dateAndGuests = 'Ngày đi & số khách';
  static const date = 'Ngày đi';
  static const chooseRooms = 'Chọn phòng';
  static String stayRange(String checkin, String checkout, int nights) =>
      'Nhận phòng $checkin · trả phòng $checkout · $nights đêm';
  static const noFreeRooms = 'Các phòng của gói đã kín đêm này. Hãy chọn ngày khác.';
  static String beds(int beds, int guests) => 'Phòng đã chọn đủ chỗ cho $beds người (đơn có $guests khách)';
  static const pickRoom = 'Hãy chọn phòng cho tour';
  static String needMoreRooms(int guests) => 'Chọn thêm phòng cho đủ $guests khách';
  static const noteForHotel = 'Ghi chú cho khách sạn';
  static const notePlaceholder = 'Điểm đón, ăn chay, trẻ em…';
  static String tourPart(String price, int guests) => 'Tiền tour ($price × $guests khách)';
  static String roomPart(int nights) => 'Tiền phòng ($nights đêm)';
  static const formNotice = 'Phòng được giữ ngay khi đặt. Khách sạn xác nhận đơn sau, thanh toán tại khách sạn.';
  static const placed = 'Đã đặt tour — chờ khách sạn xác nhận';

  // Chi tiết
  static const tour = 'Tour';
  static const stay = 'Phòng ở kèm';
  static const checkin = 'Nhận phòng';
  static const checkout = 'Trả phòng';
  static const rooms = 'Phòng';
  static const tourAmount = 'Tiền tour';
  static const roomAmount = 'Tiền phòng';
  static String viewRoomBooking(int id) => 'Xem đơn phòng #$id';
  static const tourDate = 'Ngày đi';
  static const departure = 'Khởi hành';
  static const guestCount = 'Số khách';
  static const unitPrice = 'Giá mỗi khách';
  static const total = 'Tổng tiền';
  static const payment = 'Thanh toán';
  static const paymentAtHotel = 'Tại khách sạn';
  static const note = 'Ghi chú của khách';
  static const guest = 'Khách đặt';
  static const branch = 'Khách sạn';
  static const viaAi = 'Đặt qua trợ lý AI trong tin nhắn';
  static const createdAt = 'Đặt lúc';
  static const canceledByGuest = 'Khách đã huỷ';
  static const canceledByHotel = 'Khách sạn đã huỷ';
  static const cancelReason = 'Lý do';
  static const openChat = 'Mở tin nhắn';
  static const callGuest = 'Gọi khách';
  static const callBranch = 'Gọi khách sạn';
  static const tourRemoved = 'Tour này đã bị khách sạn gỡ';
  static const waitingNotice = 'Khách sạn sẽ xác nhận đơn sớm. Bạn sẽ nhận thông báo khi có kết quả.';

  // Thao tác
  static const confirm = 'Xác nhận đơn';
  static const confirmed = 'Đã xác nhận đơn tour';
  static const complete = 'Hoàn tất';
  static const completeTitle = 'Hoàn tất đơn tour?';
  static const completeMessage = 'Dùng sau khi khách đã đi tour và thanh toán.';
  static const completed = 'Đã hoàn tất đơn tour';
  static const cancel = 'Huỷ đơn';
  static const cancelTitle = 'Huỷ đơn tour?';
  static const cancelMessageGuest = 'Khách sạn sẽ được báo là bạn huỷ đơn này.';
  static const cancelReasonTitle = 'Lý do huỷ đơn tour';
  static const cancelReasonHint = 'Khách sẽ nhận được lý do này trong thông báo.';
  static const cancelReasonRequired = 'Hãy nhập lý do huỷ';
  static const quickReasons = ['Tour đã kín chỗ', 'Thời tiết xấu', 'Không đủ khách khởi hành', 'Không liên lạc được khách'];
  static const canceled = 'Đã huỷ đơn tour';
}
