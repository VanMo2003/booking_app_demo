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
  static const trendTitle = 'Diễn biến doanh thu';
  static const trendNote =
      'Đơn đã hoàn tất: phòng (gồm dịch vụ) theo ngày trả phòng, tour theo ngày đi.';
  static String bucketCounts(String bookings, int tours) => tours == 0 ? bookings : '$bookings · $tours tour';
  static String yearOverYear(String lastYear, String? change) =>
      change == null ? 'Cùng kỳ năm trước: $lastYear' : 'Cùng kỳ năm trước: $lastYear ($change)';

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
  static const serviceAttach = 'Đơn mua dịch vụ';
  static const servicePerBooking = 'Dịch vụ TB mỗi đơn';
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
  static const byPaymentTiming = 'Thời điểm thu tiền';
  static const byPaymentTimingNote = 'Đơn hoàn tất trong kỳ, theo lúc thanh toán được ghi nhận.';
  static String paymentTimingLabel(String key) => switch (key) {
        'PREPAID' => 'Trả trước khi đến',
        'AT_STAY' => 'Trả trong thời gian ở',
        'AFTER_CHECKOUT' => 'Trả sau khi trả phòng',
        'UNPAID' => 'Chưa thu',
        'UNKNOWN' => 'Đã thu, không rõ lúc nào',
        _ => key,
      };
  static String daysToCollect(String days) => 'Đơn thu muộn trung bình $days ngày sau trả phòng mới thu được tiền';
  static String bucketProfit(String profit) => 'Sau lương $profit';
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
  static const onTheBooks = 'Phòng đã được đặt';
  static String onTheBooksNote(int booked, int available) => '$booked/$available đêm phòng đã có khách đặt';
  static String noBookedRooms(int days) => 'Chưa có phòng nào được đặt cho $days ngày tới';
  static String busiestNight(String day, int booked, int total) => 'Đông nhất $day: $booked/$total phòng';
  static String fullNights(int nights) => '$nights đêm đã kín phòng';
  static String lastYearOccupancy(String rate) => 'Cùng kỳ năm trước những đêm này lấp đầy $rate';
  static String branchOnTheBooks(int days, String rate, String? lastYear) =>
      'Đã đặt $days ngày tới: $rate${lastYear == null ? '' : ' · năm trước $lastYear'}';

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
  static const byRoomNote =
      'Tỷ lệ đêm có khách; doanh thu = tiền phòng thực thu của lượt ở đã hoàn tất.';
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
  static String nights(int n) => '$n đêm';
  static String quantity(int n) => '$n lượt';
  static const byTour = 'Doanh thu theo tour';
  static const byTourNote =
      'Tiền tour của đơn hoàn tất, theo ngày đi. Phòng trong gói tính vào doanh thu phòng khi khách trả phòng.';
  static String tourCaption(int orders, int guests) => '$orders đơn · $guests khách';
  static String aiOrders(int n) => '$n đơn do AI lên';
  static String packageRooms(String amount) => 'phòng gói $amount';
  static const roomTypeNote =
      'Tiền phòng thực thu của đơn hoàn tất (tổng đơn trừ dịch vụ), chia cho các phòng trong đơn theo giá × số đêm. '
      'Lấp đầy tính mọi đơn chưa huỷ; ADR = thực thu mỗi đêm đã bán; RevPAR = thực thu trên mỗi đêm phòng có thể bán.';
  static String roomTypeCounts(int rooms, int stays, int nights) => '$rooms phòng · $stays lượt ở · $nights đêm';
  static String roomTypeKpis(String occupancy, String adr, String revpar) =>
      'Lấp đầy $occupancy · ADR $adr · RevPAR $revpar';
  static String belowListPrice(String listPrice, String discount) => 'thấp hơn giá niêm yết $listPrice $discount';

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
  static String canceledSplit(int selfService, int frontDesk, String amount) =>
      'Đơn huỷ: $selfService khách tự đặt trên app, $frontDesk đặt tại quầy · giá trị $amount';
  static String tourCancellations(int orders, int canceled, String rate, int byGuest, int byHotel) =>
      'Tour: $orders đơn, huỷ $canceled ($rate) — khách huỷ $byGuest, khách sạn huỷ $byHotel';
  static const cancelLeadTime = 'Huỷ trước ngày nhận phòng bao lâu';
  static String cancelLeadLabel(String key) => switch (key) {
        'SAME_DAY' => 'Trong ngày nhận phòng',
        'D1_2' => '1–2 ngày trước',
        'D3_7' => '3–7 ngày trước',
        'D8_30' => '8–30 ngày trước',
        'OVER_30' => 'Hơn 30 ngày trước',
        _ => key,
      };
  static String cancelLeadCaption(String share, String amount) => '$share số đơn huỷ · $amount';
  static String lateCancellations(String share, int? medianDays) =>
      '$share đơn huỷ sát ngày (từ 2 ngày trước trở xuống)'
      '${medianDays == null ? '' : ' · thường huỷ trước $medianDays ngày'}';
  static String canceledBySide(int guest, int hotel) => 'Khách huỷ $guest đơn · khách sạn huỷ $hotel đơn';

  // Đánh giá, quê quán
  static const ratingsTitle = 'Đánh giá của khách';
  static String ratingsNote(int reviews, String rate) =>
      '$reviews đánh giá viết trong kỳ · $rate đơn hoàn tất có đánh giá';
  static String previousRating(String rating) => 'Kỳ trước $rating ★';
  static String stars(int n) => '$n sao';
  static const lowReviews = 'Đánh giá thấp gần đây';
  static String reviewLine(String customer, String date, String branch) =>
      [customer, date, if (branch.isNotEmpty) branch].join(' · ');
  static const noReviews = 'Chưa có đánh giá nào trong kỳ';
  static String branchRating(String rating, int reviews) => '★ $rating ($reviews đánh giá)';
  static const originsTitle = 'Khách đến từ đâu';
  static const unknownHometown = 'Chưa khai quê quán';
  static String originCaption(int guests, int bookings, int tours, String share) =>
      '$guests khách · $bookings đơn${tours > 0 ? ' · $tours tour' : ''} · $share doanh thu';
  static String otherOrigins(int places, String amount) => 'Còn $places nơi khác · $amount';

  // Trợ lý AI
  static const aiAssistant = 'Trợ lý AI';
  static const aiAssistantNote = 'Tin nhắn với khách trong kỳ và đơn tour trợ lý lên';
  static const aiReplyRing = 'tin do AI trả lời';
  static const aiConversations = 'Hội thoại';
  static const aiOnlyConversations = 'AI tự xử lý trọn';
  static const staffConversations = 'Có nhân viên vào cuộc';
  static const aiEmpty = 'Chưa có hội thoại hay đơn tour nào qua trợ lý trong kỳ';
  static String aiReplies(int guest, int ai, int staff) =>
      '$guest tin của khách · AI trả lời $ai tin, nhân viên $staff tin';
  static String replyTimes(int? ai, int? staff) =>
      'Thường trả lời sau (trung vị): AI ${replyDuration(ai)} · nhân viên ${replyDuration(staff)}';
  static String waitingForStaff(int count) => '$count hội thoại AI đã chuyển đang chờ nhân viên trả lời';
  static String aiTours(int orders, int completed, int open, int canceled) =>
      'Đơn tour AI lên: $orders — $completed hoàn tất, $open đang mở, $canceled huỷ';
  static String aiTourRevenue(String amount, String share) => 'Doanh thu tour AI bán: $amount ($share doanh thu tour)';

  /// 40 giây · 12 phút · 2 giờ 5 phút · 3 ngày; "—" khi chưa có.
  static String replyDuration(int? seconds) {
    if (seconds == null) return '—';
    if (seconds < 60) return '$seconds giây';
    if (seconds < 3600) return '${(seconds / 60).round()} phút';
    if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes == 0 ? '$hours giờ' : '$hours giờ $minutes phút';
    }
    return '${(seconds / 86400).round()} ngày';
  }

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
