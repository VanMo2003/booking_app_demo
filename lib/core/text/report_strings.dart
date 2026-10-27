abstract final class ReportStrings {
  static const branchReportsTitle = 'Báo cáo cơ sở';
  static const chainReportsTitle = 'Báo cáo chuỗi';

  // Tab
  static const tabRevenue = 'Doanh thu';
  static const tabOccupancy = 'Lấp đầy';
  static const tabBreakdown = 'Cơ cấu';
  static const tabPeople = 'Khách & NV';

  // Khoảng thời gian
  static const last7Days = '7 ngày qua';
  static const thisMonth = 'Tháng này';
  static const lastMonth = 'Tháng trước';
  static const thisYear = 'Năm nay';
  static const custom = 'Tuỳ chọn';

  // Độ chi tiết
  static const byDay = 'Ngày';
  static const byWeek = 'Tuần';
  static const byMonth = 'Tháng';
  static const byYear = 'Năm';

  // Doanh thu
  static const totalRevenue = 'Tổng doanh thu';
  static const completedBookings = 'Đơn hoàn tất';
  static const averagePerBooking = 'Trung bình mỗi đơn';
  static const revenueNote =
      'Đơn phòng đã hoàn tất (gồm dịch vụ), theo ngày trả phòng.';
  static const trendTitle = 'Diễn biến doanh thu phòng';

  // Tổng quan kỳ
  static String previousPeriod(String from, String to, String amount) =>
      'Kỳ trước $from – $to: $amount';
  static const noComparison = 'Kỳ trước chưa có số liệu';
  static const roomRevenue = 'Tiền phòng';
  static const serviceRevenue = 'Dịch vụ';
  static const tourRevenue = 'Tour';
  static String soldNights(int n) => '$n đêm đã bán';
  static String tourOrders(int orders, int guests) => '$orders đơn · $guests khách';
  static const adr = 'Giá TB/đêm (ADR)';
  static const revpar = 'RevPAR';
  static const occupancyShort = 'Lấp đầy';
  static String percentDelta(String sign, String value) => '$sign$value%';
  static String pointDelta(String sign, String value) => '$sign$value điểm';
  static const summaryNote =
      'Phòng và dịch vụ tính theo ngày trả phòng của đơn hoàn tất, tour theo ngày đi của đơn tour hoàn tất. '
      'ADR = tiền phòng / đêm đã bán; RevPAR = tiền phòng / đêm phòng khả dụng. '
      'Chi phí lương: phiếu lương đã duyệt hoặc đã trả, chia đều theo ngày trong tháng. '
      'Kỳ trước: tháng (hoặc từ đầu tháng) so với cùng ngày tháng trước, từ đầu năm so với cùng kỳ năm trước, '
      'khoảng khác so với cùng số ngày ngay trước đó.';
  static const grossProfit = 'Lợi nhuận sau lương';
  static const payrollCost = 'Chi phí lương';
  static String profitMargin(String margin) => 'Biên lợi nhuận $margin';
  static const sortProfit = 'Lợi nhuận';
  static const averageStay = 'Lưu trú TB';
  static const averageLead = 'Đặt trước TB';
  static String nightsDecimal(String n) => '$n đêm';
  static String daysDecimal(String n) => '$n ngày';
  static String previousValue(String value) => 'Kỳ trước: $value';
  static String canceledLoss(int canceled, int total, String amount) =>
      'Huỷ $canceled/$total đơn nhận phòng trong kỳ · mất $amount';
  static const byPaymentMethod = 'Theo phương thức thanh toán';
  static const byPaymentMethodNote = 'Đơn phòng hoàn tất. Tour trả tại khách sạn nên không tính ở đây.';
  static const byChannel = 'Theo kênh bán';
  static const channelSelfService = 'Khách tự đặt trên app';
  static const channelFrontDesk = 'Đặt tại quầy';
  static const channelTour = 'Tour';
  static String shareCaption(int count, String share) => '$count đơn · $share';
  static const byCustomerType = 'Khách mới và khách quay lại';
  static const byCustomerTypeNote = 'Khách quay lại: đã có đơn hoàn tất, trả phòng trước kỳ này.';
  static const newGuests = 'Khách mới';
  static const returningGuests = 'Khách quay lại';
  static String weekLabel(int week) => 'Tuần $week';
  static const branchComparison = 'So sánh cơ sở';
  static const branchComparisonNote =
      'Cùng khoảng ngày đang xem; tăng giảm so với kỳ trước của từng cơ sở.';
  static const sortRevenue = 'Doanh thu';
  static const sortGrowth = 'Tăng trưởng';
  static const sortOccupancy = 'Lấp đầy';
  static const sortRevpar = 'RevPAR';
  static String branchCaption(String share, String occupancy, String adr, String cancellation) =>
      'Tỷ trọng $share · Lấp đầy $occupancy · ADR $adr · Huỷ $cancellation';

  // Thẻ số liệu trên màn Tổng quan
  static String versusPreviousRange(String delta, String from, String to) => '$delta so với $from–$to';
  static String previousRangeValue(String from, String to, String value) => '$from–$to: $value';

  // Tiền chưa thu
  static const receivablesTitle = 'Tiền chưa thu';
  static String receivablesTotal(int bookings) => '$bookings đơn đã trả phòng chưa ghi nhận thanh toán';
  static const receivablesNote =
      'Thu tiền hoặc xác nhận khách đã chuyển khoản, rồi bấm "Đã thu tiền" để ghi nhận.';
  static const receivablesEmpty = 'Không còn khoản nào chưa thu';
  static const receivablesEmptyNote = 'Mọi đơn đã trả phòng đều đã được ghi nhận thanh toán.';
  static String receivableDue(String checkout, int days) =>
      days == 0 ? 'Trả phòng hôm nay ($checkout)' : 'Trả phòng $checkout · quá $days ngày';
  static String receivableConfirm(String guest, String amount) =>
      'Ghi nhận ${guest.isEmpty ? 'khách' : guest} đã thanh toán $amount?';
  static String bookingNumber(int id) => 'Đơn #$id';
  static const openBooking = 'Xem đơn';

  // Mục tiêu doanh thu tháng
  static String targetTitle(String month) => 'Mục tiêu tháng $month';
  static String targetDay(int day, int days) => 'Ngày $day/$days của tháng';
  static String targetAchieved(String revenue, String target) => '$revenue / $target';
  static String targetProjected(String amount, String rate) => 'Dự kiến cả tháng $amount ($rate)';
  static String targetShortfall(String amount) => 'còn thiếu $amount';
  static const noTarget = 'Chưa đặt mục tiêu doanh thu cho tháng này.';
  static const noChainTarget = 'Chưa cơ sở nào có mục tiêu tháng này — chạm từng cơ sở bên dưới để đặt.';
  static const noTargetShort = 'Chưa đặt';
  static const chainTargetNote = 'Tỷ lệ chỉ tính các cơ sở đã đặt mục tiêu.';
  static const setTarget = 'Đặt mục tiêu';
  static const editTarget = 'Sửa mục tiêu';
  static const removeTarget = 'Bỏ mục tiêu';
  static const targetAmount = 'Doanh thu mục tiêu';
  static const targetSaved = 'Đã lưu mục tiêu';

  // Doanh thu dự kiến
  static String outlookTitle(int days) => 'Doanh thu dự kiến $days ngày tới';
  static String outlookNote(String from, String to) =>
      '$from – $to · đơn chờ và đã xác nhận theo ngày trả phòng, tour theo ngày đi';
  static const outlookBookings = 'Đơn phòng';
  static const outlookTours = 'Tour';
  static const outlookPrepaid = 'Đã thu trước';
  static String awaitingConfirmation(String amount, int bookings) =>
      'Trong đó $amount ($bookings đơn) còn chờ xác nhận';
  static String overdueStays(int bookings, String amount) =>
      '$bookings đơn quá ngày trả phòng chưa hoàn tất · $amount';
  static String outstandingPayments(int bookings, String amount) =>
      '$bookings đơn đã trả phòng chưa ghi nhận thanh toán · $amount';

  // Lấp đầy
  static const occupancyRate = 'Tỷ lệ lấp đầy';
  static const totalRooms = 'Số phòng';
  static const roomNights = 'Đêm phòng';
  static const occupiedNights = 'Đêm có khách';
  static const occupancyNote =
      'Tính mọi đơn chưa huỷ, số đêm giao với khoảng đã chọn.';
  static const dailyOccupancy = 'Lấp đầy theo ngày';
  static const byWeekday = 'Theo thứ trong tuần';
  static const byWeekdayNote =
      'Lấp đầy trung bình mỗi thứ trong kỳ; doanh thu gồm đơn phòng (ngày trả phòng) và tour (ngày đi).';
  static String weekdayShort(int day) => day == 7 ? 'CN' : 'T${day + 1}';
  static String weekdayName(int day) => day == 7 ? 'Chủ nhật' : 'Thứ ${const ['Hai', 'Ba', 'Tư', 'Năm', 'Sáu', 'Bảy'][day - 1]}';
  static String weekdayTooltip(String day, String occupancy, String revenue) =>
      '$day · lấp đầy $occupancy · $revenue/ngày';
  static String weekdayHighlights(String busiest, String occupancy, String richest, String revenue) =>
      'Đông khách nhất: $busiest ($occupancy) · doanh thu cao nhất: $richest ($revenue/ngày)';
  static const byRoom = 'Theo từng phòng';
  static const byRoomNote = 'Tỷ lệ đêm có khách; doanh thu = giá phòng × số đêm của lượt ở đã hoàn tất.';
  static String roomLabel(String number, String type) => type.isEmpty ? 'Phòng $number' : 'Phòng $number · $type';
  static String roomCaption(int nights, String revenue) => '$nights đêm có khách · $revenue';
  static String idleRooms(String numbers) => 'Chưa có khách trong kỳ: $numbers';
  static const dailyOccupancyTooLong =
      'Chọn khoảng tối đa 92 ngày để xem lấp đầy theo ngày.';
  static const dailyOccupancyChainOnly =
      'Lấp đầy theo ngày chỉ có ở báo cáo từng cơ sở.';

  // Cơ cấu
  static const byRoomType = 'Doanh thu theo loại phòng';
  static const byService = 'Doanh thu theo dịch vụ';
  static String bookedRooms(int n) => '$n lượt phòng';
  static String nights(int n) => '$n đêm';
  static String quantity(int n) => '$n lượt';
  static const byTour = 'Doanh thu theo tour';
  static const byTourNote =
      'Tiền tour của đơn hoàn tất, theo ngày đi. Phòng trong gói tính vào doanh thu phòng khi khách trả phòng.';
  static String tourCaption(int orders, int guests) => '$orders đơn · $guests khách';
  static String aiOrders(int n) => '$n đơn do AI lên';
  static String packageRooms(String amount) => 'phòng gói $amount';
  static const roomTypeNote =
      'Doanh thu phòng tính bằng giá phòng hiện tại × số đêm.';

  // Khách & nhân viên
  static const topCustomers = 'Khách chi tiêu nhiều nhất';
  static const staffPerformance = 'Hiệu suất nhân viên';
  static const staffPerformanceNote =
      'Đơn nhận tại quầy (nhận phòng trong kỳ). Số tiền = đơn của nhân viên đã hoàn tất (trả phòng trong kỳ) '
      '+ tour nhân viên xác nhận/hoàn tất.';
  static String staffBookings(int taken, int completed) => '$taken đơn nhận · $completed hoàn tất';
  static String staffTours(int tours) => '$tours tour';
  static const cancellation = 'Tỷ lệ huỷ đơn';
  static const totalBookings = 'Tổng đơn';
  static const canceledBookings = 'Đã huỷ';
  static const completedCount = 'Hoàn tất';

  // Xuất file
  static const exporting = 'Đang tạo file Excel…';
  static String exported(String fileName) => 'Đã lưu $fileName';
  static const exportCanceled = 'Đã huỷ lưu file';

  static const noData = 'Không có số liệu trong khoảng này';
  static const detailTitle = 'Chi tiết theo mốc';
  static String rangeLabel(String from, String to, int days) =>
      '$from – $to · $days ngày';
  static String roomsOccupied(int occupied, int total) =>
      '$occupied/$total phòng có khách';
}
