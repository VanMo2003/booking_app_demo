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
      'Kỳ trước là khoảng cùng số ngày ngay trước kỳ đang xem.';
  static const byPaymentMethod = 'Theo phương thức thanh toán';
  static const byPaymentMethodNote = 'Đơn phòng hoàn tất. Tour trả tại khách sạn nên không tính ở đây.';
  static const byChannel = 'Theo kênh bán';
  static const channelSelfService = 'Khách tự đặt trên app';
  static const channelFrontDesk = 'Đặt tại quầy';
  static const channelTour = 'Tour';
  static String shareCaption(int count, String share) => '$count đơn · $share';
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

  // Lấp đầy
  static const occupancyRate = 'Tỷ lệ lấp đầy';
  static const totalRooms = 'Số phòng';
  static const roomNights = 'Đêm phòng';
  static const occupiedNights = 'Đêm có khách';
  static const occupancyNote =
      'Tính mọi đơn chưa huỷ, số đêm giao với khoảng đã chọn.';
  static const dailyOccupancy = 'Lấp đầy theo ngày';
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
  static const staffPerformanceNote = 'Chỉ tính đơn được tạo tại quầy.';
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
